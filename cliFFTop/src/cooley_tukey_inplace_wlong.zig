const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;

const print = std.debug.print;

const utils = @import("utils");
const complex_math = @import("complex_math");

const add = complex_math.add;
const sub = complex_math.sub;
const mul = complex_math.mul;




const bitRevPermute = utils.bitRevPermute;

// Van Loan - Computational Frameworks for the fast fourier transform
// algorithm 1.6.2 - A unit stride formulation

pub fn fft(comptime T: type, n_fft: usize, w: []T, x:[]T) void {

    std.debug.assert(w.len == x.len-1);

    // n_fft : fft size
    // w : twiddle table (long)
    // x : input / output sequence

    const t = math.log2(n_fft);

    bitRevPermute(T, t, x[0..n_fft]);

    var q: usize = 1;
    while(q <= t):(q+=1) {
        const L : usize = math.shl(usize, 1, q);
        const r : usize = n_fft/L;
        const Lstar: usize = L/2;

        var k: usize = 0;
        while(k<r):(k+=1){

            var j: usize = 0;
            while(j<Lstar):(j+=1) {

                const tau: T = mul(w[Lstar - 1 + j], x[k*L + j + Lstar]);
                x[k*L + j + Lstar] = sub(x[k*L + j], tau);
                x[k*L + j] = add(x[k*L + j], tau);

            }
        }
    }
}


