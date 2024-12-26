const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;
const print = std.debug.print;

const utils = @import("utils");

const ValueType = utils.ValueType;

const add = @import("complex_math").add;
const addI = @import("complex_math").addI;
const I = @import("complex_math").I;
const negI = @import("complex_math").negI;
const sub = @import("complex_math").sub;
const subI = @import("complex_math").subI;
const mul = @import("complex_math").mul;
const mulConj = @import("complex_math").mulConj;
const mulI = @import("complex_math").mulI;
const scale = @import("complex_math").scale;

// ...............................................................................
// Butterflies for the conjugate pair FFT

pub fn conjPair(comptime C: type, s: usize, out: [*]C, w: C) void {

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const alpha = mul(w, c);
    const beta = mulConj(d, w);

    // out[0] = a + (w * c + conj(w) * d)
    out[0] = add(a, add(alpha, beta));

    // out[s] = b - I * (w * c - conj(w) * d)
    out[s] = subI(b, sub(alpha, beta));

    // out[s * 2] = a - (w * c + conj(w) * d)
    out[s * 2] = sub(a, add(alpha, beta));

    // out[s * 3] = b + I * (w * c - conj(w) * d)
    out[s * 3] = addI(b, sub(alpha, beta));
}

pub fn conjPair_0(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const rsu: T = c.re + d.re;
    const rsb: T = c.re - d.re;

    const isu: T = c.im + d.im;
    const isb: T = c.im - d.im;

    out[0].re = a.re + rsu;
    out[0].im = a.im + isu;

    out[s].re = b.re + isb;
    out[s].im = b.im - rsb;

    out[s * 2].re = a.re - rsu;
    out[s * 2].im = a.im - isu;

    out[s * 3].re = b.re - isb;
    out[s * 3].im = b.im + rsb;
}

pub fn conjPair_pi4(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a = out[0];
    const b = out[s];
    const c = out[s * 2];
    const d = out[s * 3];

    const rc: T = math.sqrt1_2 * c.re;
    const ic: T = math.sqrt1_2 * c.im;

    const rd: T = math.sqrt1_2 * d.re;
    const id: T = math.sqrt1_2 * d.im;

    const wcr: T = ic + rc;
    const wci: T = ic - rc;

    const cwdr: T = rd - id;
    const cwdi: T = rd + id;

    const rsu: T = wcr + cwdr;
    const isu: T = wci + cwdi;

    const rsb: T = wcr - cwdr;
    const isb: T = wci - cwdi;

    out[0].re = a.re + rsu;
    out[0].im = a.im + isu;

    out[s].re = b.re + isb;
    out[s].im = b.im - rsb;

    out[s * 2].re = a.re - rsu;
    out[s * 2].im = a.im - isu;

    out[s * 3].re = b.re - isb;
    out[s * 3].im = b.im + rsb;
}

// --------------------------------------------------------------------------------
// Butterflies for the radix 2 Cooley-Tukey FFT

pub fn cooley2(comptime C: type, s: usize, out: []C, w: C) void {
    const a = out[0];

    const b = mul(out[s], w);

    out[0] = add(a, b);
    out[s] = sub(a, b);
}

pub fn cooley2_0(comptime C: type, so: usize, si: usize, out: []C, in: []C) void {
    const a: C = in[0];
    const b: C = in[si];

    out[0] = add(a, b);
    out[so] = sub(a, b);
}

pub fn cooley2_pi4(comptime C: type, s: usize, out: []C) void {
    const a: C = out[0];
    const b: C = out[s];

    const t = C.init(math.sqrt1_2 * (b.re + b.im), math.sqrt1_2 * (b.im - b.re));

    out[0] = add(a, t);
    out[s] = sub(a, t);
}

pub fn cooley2_pi2(comptime C: type, s: usize, out: []C) void {
    const a: C = out[0];
    const b: C = out[s];

    const t = C.init(b.im, -b.re);

    out[0] = add(a, t);
    out[s] = sub(a, t);
}

pub fn cooley2_3pi4(comptime C: type, s: usize, out: []C) void {
    const a: C = out[0];
    const b: C = out[s];

    const t = C.init(math.sqrt1_2 * (-b.re + b.im), math.sqrt1_2 * (-b.im - b.re));

    out[0] = add(a, t);
    out[s] = sub(a, t);
}

pub fn cooley2_dif(comptime C: type, s: usize, out: []C, w: C) void {
    const a = out[0];
    const b = out[s];

    const alpha = sub(a, b);

    out[0] = add(a, b);
    out[s] = mul(alpha, w);
}

pub fn cooley2_dif_0(comptime C: type, so: usize, si: usize, out: []C, in: []C) void {
    const a = in[0];
    const b = in[si];

    out[0] = add(a, b);
    out[so] = sub(a, b);
}

// ----------------------------------------------------------------------------
// Radix-4 butterflies for the mixed radix FFT

pub fn mixedRad4(comptime C: type, s: usize, out: []C, w1: C, w2: C, w3: C) void {
    const a = out[0];
    const b = mul(out[s], w1);
    const c = mul(out[s * 2], w2);
    const d = mul(out[s * 3], w3);

    const e = add(a, c);
    const f = sub(a, c);
    const g = add(b, d);
    const j = I(sub(b, d));

    out[0] = add(e, g);
    out[s] = sub(f, j);
    out[s * 2] = sub(e, g);
    out[s * 3] = add(f, j);
}

pub fn mixedRad4_0(comptime C: type, so: usize, si: usize, out: []C, in: []C) void {
    const a: C = in[0];
    const b: C = in[si];
    const c: C = in[si * 2];
    const d: C = in[si * 3];

    const e = add(a, c);
    const f = sub(a, c);
    const g = add(b, d);
    const j = I(sub(b, d));

    out[0] = add(e, g);
    out[so] = sub(f, j);
    out[so * 2] = sub(e, g);
    out[so * 3] = add(f, j);
}

pub fn mixedRad4_1(comptime C: type, s: usize, out: []C) void {
    const a = out[0];
    const c = negI(out[s * 2]);

    const b_tmp = scale(out[s], math.sqrt1_2);
    const d_tmp = scale(out[s * 3], math.sqrt1_2);

    const b = C.init(b_tmp.im + b_tmp.re, b_tmp.im - b_tmp.re);
    const d = C.init(d_tmp.im - d_tmp.re, -d_tmp.im - d_tmp.re);

    const e = add(a, c);
    const f = sub(a, c);
    const g = add(b, d);
    const j = I(sub(b, d));

    out[0] = add(e, g);
    out[s] = sub(f, j);
    out[s * 2] = sub(e, g);
    out[s * 3] = add(f, j);
}

// --------------------------------------------------------------------------------
// Butterflies for the split-radix FFT

pub fn splitRad4(comptime C: type, s: usize, out: [*]C, w1: C, w3: C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const w1c_re: T = w1.re * c.re - w1.im * c.im;
    const w1c_im: T = w1.re * c.im + w1.im * c.re;

    const w3d_re: T = w3.re * d.re - w3.im * d.im;
    const w3d_im: T = w3.re * d.im + w3.im * d.re;

    // out[0]     = a +     (w1 * c + w3 * d);
    out[0].re = a.re + (w1c_re + w3d_re);
    out[0].im = a.im + (w1c_im + w3d_im);

    // out[s]     = b - I * (w1 * c - w3 * d);
    out[s].re = b.re + (w1c_im - w3d_im);
    out[s].im = b.im - (w1c_re - w3d_re);

    // out[s * 2] = a -     (w1 * c + w3 * d);
    out[s * 2].re = a.re - (w1c_re + w3d_re);
    out[s * 2].im = a.im - (w1c_im + w3d_im);

    // out[s * 3] = b + I * (w1 * c - w3 * d);
    out[s * 3].re = b.re + (-w1c_im + w3d_im);
    out[s * 3].im = b.im + (w1c_re - w3d_re);
}

pub fn splitRad4_0(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const rsu: T = c.re + d.re;
    const rsb: T = c.re - d.re;
    const isu: T = c.im + d.im;
    const isb: T = c.im - d.im;

    out[0] = C.init(a.re + rsu, a.im + isu);
    out[s] = C.init(b.re + isb, b.im - rsb);
    out[s * 2] = C.init(a.re - rsu, a.im - isu);
    out[s * 3] = C.init(b.re - isb, b.im + rsb);
}

pub fn splitRad4_pi4(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    // double rc   = M_SQRT1_2 * creal(c);
    const rc: T = math.sqrt1_2 * c.re;

    // double rd   = M_SQRT1_2 * creal(d);
    const rd: T = math.sqrt1_2 * d.re;

    // double ic   = M_SQRT1_2 * cimag(c);
    const ic: T = math.sqrt1_2 * c.im;

    // double id   = M_SQRT1_2 * cimag(d);
    const id: T = math.sqrt1_2 * d.im;

    // double wcr  = ic + rc;
    const wcr: T = ic + rc;

    // double wci  = ic - rc;
    const wci: T = ic - rc;

    // double wdr  = -rd + id;
    const wdr: T = -rd + id;

    // double wdi  = -rd - id;
    const wdi: T = -rd - id;

    // double rsu  = wcr + wdr;
    const rsu: T = wcr + wdr;

    // double rsb  = wcr - wdr;
    const rsb: T = wcr - wdr;

    // double isu  = wci + wdi;
    const isu: T = wci + wdi;

    // double isb  = wci - wdi;
    const isb: T = wci - wdi;

    // out[0]     = CMPLX(creal(a) + rsu, cimag(a) + isu);
    out[0].re = a.re + rsu;
    out[0].im = a.im + isu;

    // out[s]     = CMPLX(creal(b) + isb, cimag(b) - rsb);
    out[s].re = b.re + isb;
    out[s].im = b.im - rsb;

    // out[s * 2] = CMPLX(creal(a) - rsu, cimag(a) - isu);
    out[s * 2].re = a.re - rsu;
    out[s * 2].im = a.im - isu;

    // out[s * 3] = CMPLX(creal(b) - isb, cimag(b) + rsb);
    out[s * 3].re = b.re - isb;
    out[s * 3].im = b.im + rsb;
}

// TESTS -------------------------------------------------------------------------

test "testing conjPair" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;
    const w = C.init(  1.300,   0.700);

    conjPair(C, s, &out, w);

    try std.testing.expectApproxEqAbs( @as(f64,   5.0500000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.0900000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   8.1700000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.4300000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -2.4500000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   4.1100000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -1.5700000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.5700000), out[3].im, eps);
}

test "testing conjPair_0" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    conjPair_0(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   5.1000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   1.2000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   5.0000000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.7000000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -2.5000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   3.0000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.6000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.3000000), out[3].im, eps);
}

test "testing conjPair_pi4" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    conjPair_pi4(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   5.1890873), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.3121320), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.8150758), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.9849242), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -2.5890873), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   1.8878680), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   4.7849242), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.0150758), out[3].im, eps);
}

test "testing cooley2" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;
    const w = C.init(  1.300,   0.700);

    cooley2(C, s, &out, w);

    try std.testing.expectApproxEqAbs( @as(f64,   4.5400000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   6.3600000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -1.9400000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -2.1600000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing cooley2_0" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var in = [_]C{ C.init(2.1, -2.1), C.init(1.3, 1.7), C.init(-1.3,  0.7), C.init(-2.5, 1.1)};
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const si: usize = 1;
    const so: usize = 1;

    cooley2_0(C, so, si, &out, &in);

    try std.testing.expectApproxEqAbs( @as(f64,   3.4000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -0.4000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   0.8000000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -3.8000000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing cooley2_pi4" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    cooley2_pi4(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   4.6941125), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.8272078), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -2.0941125), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   3.3727922), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing cooley2_pi2" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    cooley2_pi2(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   2.8000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.2000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -0.2000000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   5.4000000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing cooley2_3pi4" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    cooley2_3pi4(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   0.0272078), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.2941125), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5727922), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   5.4941125), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing cooley2_dif" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;
    const w = C.init(  1.300,   0.700);

    cooley2_dif(C, s, &out, w);

    try std.testing.expectApproxEqAbs( @as(f64,   4.6000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   3.6000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -3.0200000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -0.6200000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing cooley2_dif_0" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var in = [_]C{ C.init(2.1, -2.1), C.init(1.3, 1.7), C.init(-1.3,  0.7), C.init(-2.5, 1.1)};
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const si: usize = 1;
    const so: usize = 1;

    cooley2_dif_0(C, so, si, &out, &in);

    try std.testing.expectApproxEqAbs( @as(f64,   3.4000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -0.4000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   0.8000000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -3.8000000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.4000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.5000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3000000), out[3].im, eps);
}

test "testing mixedRad4" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;
    const w1 = C.init(  1.300,   0.700);
    const w2 = C.init( -3.100,   1.300);
    const w3 = C.init(  0.200,  -0.600);

    mixedRad4(C, s, &out, w1, w2, w3);

    try std.testing.expectApproxEqAbs( @as(f64,  -0.2900000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   5.0500000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  11.8700000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.8700000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -6.2100000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.0500000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -0.1700000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   5.1700000), out[3].im, eps);
}

test "testing mixedRad4_0" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var in = [_]C{ C.init(2.1, -2.1), C.init(1.3, 1.7), C.init(-1.3,  0.7), C.init(-2.5, 1.1)};
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const so: usize = 1;
    const si: usize = 1;

    mixedRad4_0(C, so, si, &out, &in);

    try std.testing.expectApproxEqAbs( @as(f64,  -0.4000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   1.4000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   4.0000000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -6.6000000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.0000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -4.2000000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.8000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   1.0000000), out[3].im, eps);
}

test "testing mixedRad4_1" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    mixedRad4_1(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   2.4071068), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -1.3213203), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   0.4757359), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -2.6811183), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   0.9928932), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.9213203), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.3242641), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   9.4811183), out[3].im, eps);
}

test "testing splitRad4" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;
    const w1 = C.init(  1.300,   0.700);
    const w3 = C.init(  0.200,  -0.600);

    splitRad4(C, s, &out, w1, w3);

    try std.testing.expectApproxEqAbs( @as(f64,   2.4300000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   1.7700000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   6.4900000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -0.1900000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   0.1700000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.4300000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   0.1100000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   3.1900000), out[3].im, eps);
}

test "testing splitRad4_0" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    splitRad4_0(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,   5.1000000), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   1.2000000), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   5.0000000), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   2.7000000), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,  -2.5000000), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   3.00000), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   1.6000000), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.3000000), out[3].im, eps);
}

test "testing splitRad4_pi4" { 
    const eps = 1e-5;
    const C = Complex(f64);
    var out = [_]C{ C.init(1.3, 2.1), C.init(3.3, 1.5), C.init(1.3,  0.4), C.init(2.5, -1.3)};
    const s: usize = 1;

    splitRad4_pi4(C, s, &out);

    try std.testing.expectApproxEqAbs( @as(f64,  -0.1849242), out[0].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   0.6150758), out[0].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   3.5121320), out[1].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,  -2.3890873), out[1].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   2.7849242), out[2].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   3.5849242), out[2].im, eps);

    try std.testing.expectApproxEqAbs( @as(f64,   3.0878680), out[3].re, eps);
    try std.testing.expectApproxEqAbs( @as(f64,   5.3890873), out[3].im, eps);
}

