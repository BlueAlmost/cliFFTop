const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const utils = @import("utils");
const complex_math = @import("complex_math");
const butterflies = @import("butterflies");

const add = complex_math.add;
const mul = complex_math.mul;
const sub = complex_math.sub;
const neg = complex_math.neg;
const conj = complex_math.conj;
const conjI = complex_math.conjI;

const bitRevSwapBits = @import("utils").bitRevSwapBits;

const conjPair = @import("butterflies").conjPair;
const conjPair_0 = @import("butterflies").conjPair_0;
const conjPair_pi4 = @import("butterflies").conjPair_pi4;

const mixedRad4 = @import("butterflies").mixedRad4;
const mixedRad4_0 = @import("butterflies").mixedRad4_0;
const mixedRad4_1 = @import("butterflies").mixedRad4_1;

const cooley2_0 = @import("butterflies").cooley2_0;

const get_twiddle = @import("Twiddles").Std.get;
const get_twiddle_mr = @import("Twiddles").Std.get_mr;

pub fn fft(comptime C: type, N: usize, w: []C, out: []C, in: []C) void {

    std.debug.assert(w.len == in.len);

    const log2_N: usize = math.log2(N);

    // stage 0
    if (log2_N & 1 == 1) {
        var i: usize = 0;
        while (i < N) : (i += 4) {
            const r = bitRevSwapBits(i, log2_N);
            cooley2_0(C, 1, N / 2, out[i..], in[r..]);
            cooley2_0(C, 1, N / 2, out[i+2..], in[(r+N/8)..]);
        }
    } else {
        var i: usize = 0;
        while (i < N) : (i += 4) {
            const r = bitRevSwapBits(i, log2_N);
            mixedRad4_0(C, 1, N / 4, out[i..], in[r..]);
        }
    }

    // higher stages
    var j: usize = 2 - (log2_N & 1);
    while (j < log2_N) : (j += 2) {
        const s: usize = log2_N - (j + 2);
        const l: usize = math.shl(usize, 1, j);

        var i: usize = 0;
        while (i < math.shl(usize, 1, s)) : (i += 1) {
            const t: []C = out[math.shl(usize, i, j + 2)..];

            mixedRad4_0(C, l, l, t, t);
            mixedRad4_1(C, l, t[(l/2)..]);

            var k: usize = 1;
            while (k < l / 2) : (k += 1) {

                const w1 = w[math.shl(usize, k, s)];
                const w2 = w[math.shl(usize, k * 2, s)];
                const w3 = w[math.shl(usize, k * 3, s)];

                mixedRad4(C, l, t[k..], w1, w2, w3);
                mixedRad4(C, l, t[(l-k)..], conjI(w1), neg(conj(w2)), neg(conjI(w3)));
            }
        }
    }
}
