const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const utils = @import("utils");
const complex_math = @import("complex_math");
const butterflies = @import("butterflies");

const mixed_radix = @import("mixed_radix.zig").fft;

const add = complex_math.add;
const addConj = complex_math.addConj;

const sub = complex_math.sub;
const subConj = complex_math.subConj;

const neg = complex_math.neg;
const conj = complex_math.conj;

const mul = complex_math.mul;

const scale = complex_math.scale;
const scaleI = complex_math.scaleI;

pub fn rfft(comptime R: type, n_real: usize, w: []Complex(R), w_edson: []Complex(R), out_cmpx: []Complex(R), in_real: []R) void {

    std.debug.assert(in_real.len == 2*w.len);
    std.debug.assert(in_real.len == 2*w_edson.len);

    // n_real is the length of the real-valued input vector ("in_real")
    // w is the twiddle lut for the mixed-radix complex valued fft (n_real/2)
    // w_edson is twiddle lut need for unfolding segment of complex to real
    // "out" is length n_real+1 complex-valued fft of "in" (from freq = 0 to fs/2)

    const C = Complex(R);
    const n2 = n_real/2;
    const n4 = n_real/4;

    // re-interpret length N real slice as length N/2 complex slice
    const in_cmpx = std.mem.bytesAsSlice(C, std.mem.sliceAsBytes(in_real));


    mixed_radix(C, n2, w, out_cmpx, in_cmpx);

    const even_tmp = C.init(out_cmpx[0].re, 0.0);
    const odd_tmp  = C.init(out_cmpx[0].im, 0.0);

    out_cmpx[0] = add(even_tmp, odd_tmp);
    out_cmpx[n2] = sub(even_tmp, odd_tmp);

    var k: usize = 1;
    while(k<=n4):(k+=1) {
        const lo: usize = k;
        const hi: usize = n2-k;

        // temporary variables
        var even_lo: C = addConj(out_cmpx[lo], out_cmpx[hi]);
        even_lo = scale(even_lo, 0.5);

        var odd_lo: C = subConj(out_cmpx[lo], out_cmpx[hi]);
        odd_lo = scaleI(odd_lo, -0.5);

        var even_hi: C = addConj(out_cmpx[hi], out_cmpx[lo]);
        even_hi = scale(even_hi, 0.5);

        var odd_hi: C = subConj(out_cmpx[hi], out_cmpx[lo]);
        odd_hi = scaleI(odd_hi, -0.5);

        out_cmpx[lo] = add( even_lo,  mul(w_edson[lo], odd_lo));
        out_cmpx[hi] = add( even_hi,  mul(w_edson[hi], odd_hi));
    }
}

