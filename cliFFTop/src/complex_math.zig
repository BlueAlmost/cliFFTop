const std = @import("std");
const Complex = std.math.Complex;
const print = std.debug.print;

// Unary Operations,  for complex number x
// ========================================================
//
//   neg(x)           -x
//   negI(x)          -i*x
//   negIConj(x)      -i*conj(x)
//
//   I(x)              i*x
//   IConj(x)          i*conj(x)
//
//   conj(x)           conjugate of x
//
//   negConj          -conj(x)
//   conjI(x)          conj(i*x)
//
//   these two are equivalent:
//   negConjI(x)      -conj(i*x)
//   conjNegI(x)      conj(-i*x)
//
//
// Binary Operations,  for complex numbers x and y, beta real
// ==========================================================
// 
//   scale(x, beta)     beta*x  (where beta is a real)
//   scaleI(x, beta)    i*beta*x  (where beta is a real)
//
//   add(x, y)          x+y
//   addI(x, y)         x+i*y
//   addConj(x, y)      x+conj(y)
//   addConjI(x, y)     x+conj(i*y)
//
//   sub(x, y)          x-y
//   subI(x, y)         x-i*y
//   subConj(x, y)      x-conj(y)
//   subConjI(x, y)     x-conj(i*y)
//
//   mul(x, y)          x*y
//   mulI(x,y)          x*(i*y)
//   mulNeg(x,y)        x*(-y)
//   mulNegI(x,y)       x*(-i*y)
//
//   mulConj(x,y)       x*conj(y)
//   mulConjI(x,y)      x*conj(i*y)
//
//   div(x, y)          x/y

pub inline fn neg(a: anytype) @TypeOf(a){
    //returns -x
    return @TypeOf(a).init(-a.re, -a.im);
}
pub inline fn negI(a: anytype) @TypeOf(a){
    //returns -i*x
    return @TypeOf(a).init(a.im, -a.re);
}

pub inline fn negIConj(a: anytype) @TypeOf(a){
    //returns -i*conj(x)
    return @TypeOf(a).init(-a.im, -a.re);
}

pub inline fn I(a: anytype) @TypeOf(a) {
    //returns i*x
    return @TypeOf(a).init(-a.im, a.re);
}

pub inline fn IConj(a: anytype) @TypeOf(a) {
    // returns i*conj(x)
    return @TypeOf(a).init(a.im, a.re);
}

pub inline fn conj(a: anytype) @TypeOf(a) {
    // returns conjugate of x
    return @TypeOf(a).init(a.re, -a.im);
}

pub inline fn negConj(a: anytype) @TypeOf(a) {
    // returns conj(-x)
    return @TypeOf(a).init(-a.re, a.im);
}

pub inline fn conjI(a: anytype) @TypeOf(a) {
    // returns conj(i*x)
    return @TypeOf(a).init(-a.im, -a.re);
}



pub inline fn negConjI(a: anytype) @TypeOf(a) {
    // return -conj(i*x)   This is same as conj(-i*x)
    return @TypeOf(a).init(a.im, a.re);
}


pub inline fn conjNegI(a: anytype) @TypeOf(a) {
    // return conj(-i*x)   This is same as -conj(i*x)
    return @TypeOf(a).init(a.im, a.re);
}

// Binary Operations -----------------------------------------------

pub inline fn scale(a: anytype, beta: @TypeOf(a.re)) @TypeOf(a) {
    // returns a*beta (where beta is a real number)
    return @TypeOf(a).init(beta * a.re, beta * a.im);
}

pub inline fn scaleI(a: anytype, beta: @TypeOf(a.re)) @TypeOf(a) {
    // returns i*a*beta (where beta is a real number)
    return @TypeOf(a).init(-beta * a.im, beta * a.re);
}

pub inline fn add(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+b
    return @TypeOf(a).init(a.re + b.re, a.im + b.im);
}

pub inline fn addI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+ib
    return @TypeOf(a).init(a.re - b.im, a.im + b.re);
}

pub inline fn addConj(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+conj(b)
    return @TypeOf(a).init(a.re + b.re, a.im - b.im);
}

pub inline fn addConjI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+conj(ib)
    return @TypeOf(a).init(a.re - b.im, a.im - b.re);
}

pub inline fn sub(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-b
    return @TypeOf(a).init(a.re - b.re, a.im - b.im);
}

pub inline fn subI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-ib
    return @TypeOf(a).init(a.re + b.im, a.im - b.re);
}

pub inline fn subConj(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-conj(b)
    return @TypeOf(a).init(a.re - b.re, a.im + b.im);
}

pub inline fn subConjI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-conj(ib)
    return @TypeOf(a).init(a.re + b.im, a.im + b.re);
}

pub inline fn mul(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*b
    return @TypeOf(a).init(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
}

pub inline fn mulI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*i*b
    return @TypeOf(a).init(-a.re * b.im - a.im * b.re, a.re * b.re - a.im * b.im);
}

pub inline fn mulNeg(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns -a*b
    return @TypeOf(a).init(-a.re * b.re + a.im * b.im, -a.re * b.im - a.im * b.re);
}

pub inline fn mulNegI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns -a*i*b
    return @TypeOf(a).init(a.re * b.im + a.im * b.re, -a.re * b.re + a.im * b.im);
}

pub inline fn mulConj(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*conj(b)
    return @TypeOf(a).init(a.re * b.re + a.im * b.im, -a.re * b.im + a.im * b.re);
}

pub inline fn mulConjI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*conj(ib)
    return @TypeOf(a).init(-a.re * b.im + a.im * b.re, -a.re * b.re - a.im * b.im);
}

pub inline fn div(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    const den: @TypeOf(a.re) = b.re * b.re + b.im * b.im;

    return @TypeOf(a).init((a.re * b.re + a.im * b.im) / den, (a.im * b.re - a.re * b.im) / den);
}


test "complex math tests" {

    const eps = 1e-6;

    const C = Complex(f64);

    const a = C.init(1.0, 2.0);
    const b = C.init(0.1, 0.2);
    const d = C.init(-1.1, 2.6);
    const e = C.init(-1.1, 2.2);
    const beta: f64 = 3.0;

    var x: C = undefined;

    x = neg(a);
    try std.testing.expectApproxEqAbs(x.re, -1.0, eps);
    try std.testing.expectApproxEqAbs(x.im, -2.0, eps);

    x = negI(a);
    try std.testing.expectApproxEqAbs(x.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, -1.0, eps);

    x = negIConj(a);
    try std.testing.expectApproxEqAbs(x.re, -2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, -1.0, eps);

    x = I(a);
    try std.testing.expectApproxEqAbs(x.re, -2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.0, eps);

    x = IConj(a);
    try std.testing.expectApproxEqAbs(x.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.0, eps);

    x = conj(a);
    try std.testing.expectApproxEqAbs(x.re, 1.0, eps);
    try std.testing.expectApproxEqAbs(x.im, -2.0, eps);

    x = negConj(a);
    try std.testing.expectApproxEqAbs(x.re, -1.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 2.0, eps);

    x = conjI(a);
    try std.testing.expectApproxEqAbs(x.re, -2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, -1.0, eps);

    x = negConjI(a);
    try std.testing.expectApproxEqAbs(x.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.0, eps);
    
    x = conjNegI(a);
    try std.testing.expectApproxEqAbs(x.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.0, eps);

    x = scale(a, beta);
    try std.testing.expectApproxEqAbs(x.re, 3.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 6.0, eps);

    // Binary Tests -----------------------------------------------


    x = scale(a, beta);
    try std.testing.expectApproxEqAbs(x.re, 3.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 6.0, eps);


    x = scaleI(a, beta);
    try std.testing.expectApproxEqAbs(x.re, -6.0, eps);
    try std.testing.expectApproxEqAbs(x.im, 3.0, eps);


    x = addI(a, b);
    try std.testing.expectApproxEqAbs(x.re, 0.8, eps);
    try std.testing.expectApproxEqAbs(x.im, 2.1, eps);

    x = addConj(a, b);
    try std.testing.expectApproxEqAbs(x.re, 1.1, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.8, eps);

    x = addConjI(a, b);
    try std.testing.expectApproxEqAbs(x.re, 0.8, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.9, eps);

    x = subI(a, b);
    try std.testing.expectApproxEqAbs(x.re, 1.2, eps);
    try std.testing.expectApproxEqAbs(x.im, 1.9, eps);

    x = subConj(a, b);
    try std.testing.expectApproxEqAbs(x.re, 0.9, eps);
    try std.testing.expectApproxEqAbs(x.im, 2.2, eps);

    x = subConjI(a, b);
    try std.testing.expectApproxEqAbs(x.re, 1.2, eps);
    try std.testing.expectApproxEqAbs(x.im, 2.1, eps);

    x = mulI(a, d);
    try std.testing.expectApproxEqAbs(x.re, -0.4, eps);
    try std.testing.expectApproxEqAbs(x.im, -6.3, eps);

    x = mulNeg(a, d);
    try std.testing.expectApproxEqAbs(x.re, 6.3, eps);
    try std.testing.expectApproxEqAbs(x.im, -0.4, eps);

    x = mulNegI(a, d);
    try std.testing.expectApproxEqAbs(x.re, 0.4, eps);
    try std.testing.expectApproxEqAbs(x.im, 6.3, eps);

    x = mulConj(a, d);
    try std.testing.expectApproxEqAbs(x.re, 4.1, eps);
    try std.testing.expectApproxEqAbs(x.im, -4.8, eps);

    x = mulConjI(a, d);
    try std.testing.expectApproxEqAbs(x.re, -4.8, eps);
    try std.testing.expectApproxEqAbs(x.im, -4.1, eps);

    x = div(a, e);
    try std.testing.expectApproxEqAbs(x.re, 0.54545454, eps);
    try std.testing.expectApproxEqAbs(x.im, -0.72727272, eps);
}
