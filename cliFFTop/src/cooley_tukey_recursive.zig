const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;

const print = std.debug.print;

const utils = @import("utils");
const complex_math = @import("complex_math");

const add = complex_math.add;
const sub = complex_math.sub;
const mul = complex_math.mul;


pub fn fft(comptime T: type, n_fft: usize, s: usize, w: []T, y:[]T, x:[]T) void {

    // T : data type
    // n_fft : fft size
    // s : stride
    // w : twiddle table (long)
    // y : output sequence
    // x : input sequence

    const m = n_fft/2;

    if( n_fft == 1) {
        y[0] = x[0];
    }
    else {
        fft(T, n_fft>>1, s<<1, w, y, x);
        fft(T, n_fft>>1, s<<1, w, y[m..], x[s..]);

        var k: usize = 0;
        while(k<m):(k+=1) {
            const a = y[k];
            const b = mul(w[s*k], y[k+m]);
            y[k] = add(a, b);
            y[k+m] = sub(a,b);
        }
    }
}

