const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const utils = @import("utils");

const ValueType = utils.ValueType;

pub const LUTtype = enum {
    full,
    half,
    quarter,
    long, 
    none, 
};

pub fn lut(comptime C: type, comptime lut_type: LUTtype, allocator: Allocator, n_fft: usize) ![]C {

    const T = ValueType(C);

    switch(lut_type) {

        .full => {
            const theta0: T = 2.0 * math.pi / @as(T, @floatFromInt(n_fft));
            var w = try allocator.alloc(C, n_fft);
            for(w, 0..) |_, i| {
                w[i].re = @cos(@as(T, @floatFromInt(i)) * theta0);
                w[i].im = -@sin(@as(T, @floatFromInt(i)) * theta0);
            }
            return w;
        },

        .half => {
            const theta0: T = 2.0 * math.pi / @as(T, @floatFromInt(n_fft));
            var w = try allocator.alloc(C, n_fft/2);
            for(w, 0..) |_, i| {
                w[i].re = @cos(@as(T, @floatFromInt(i)) * theta0);
                w[i].im = -@sin(@as(T, @floatFromInt(i)) * theta0);
            }
            return w;
        },

        .quarter => {
            const theta0: T = 2.0 * math.pi / @as(T, @floatFromInt(n_fft));
            var w = try allocator.alloc(C, n_fft/4);
            for(w, 0..) |_, i| {
                w[i].re = @cos(@as(T, @floatFromInt(i)) * theta0);
                w[i].im = -@sin(@as(T, @floatFromInt(i)) * theta0);
            }
            return w;
        },

        .long => {
            var w = try allocator.alloc(C, n_fft-1);
            const m = math.log2(n_fft);

            var i: usize = 0;
            var count: usize = 0;
            while(i < m) : (i += 1) {
                var j: usize = 0;
                while( j < math.shl(usize, 1, i)) : (j += 1) {
                    const theta: T = math.pi * @as(T, @floatFromInt(j)) / @as(T, @floatFromInt(math.shl(usize, 1, i)));
                    w[count].re = @cos(theta);
                    w[count].im = -@sin(theta);
                    count += 1;
                }
            }
            return w;
        },

        .none => {
        },
    }
}

test "lut test" {

    const eps = 1e-5;
    const n_fft = 8;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{f32, f64}) |T| {
        
        const C = Complex(T);
        const w = try lut(C, LUTtype.full, allocator, n_fft);

        try std.testing.expectApproxEqAbs( @as(T,  1.0       ), w[0].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678), w[1].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[2].re, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[3].re, eps);
        try std.testing.expectApproxEqAbs( @as(T, -1.0       ), w[4].re, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[5].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[6].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678), w[7].re, eps);

        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[0].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[1].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -1.0       ), w[2].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[3].im, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[4].im, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678), w[5].im, eps);
        try std.testing.expectApproxEqAbs( @as(T,  1.0       ), w[6].im, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678), w[7].im, eps);
    }

    inline for (.{f32, f64}) |T| {
        
        const C = Complex(T);
        const lut_type = LUTtype.half;

        const w = try lut(C, lut_type, allocator, n_fft);

        try std.testing.expectApproxEqAbs( @as(T,  1.0       ), w[0].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678), w[1].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[2].re, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[3].re, eps);

        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[0].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[1].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -1.0       ), w[2].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[3].im, eps);
    }

    inline for (.{f32, f64}) |T| {
        
        const C = Complex(T);
        const lut_type = LUTtype.quarter;

        const w = try lut(C, lut_type, allocator, n_fft);

        try std.testing.expectApproxEqAbs( @as(T,  1.0       ), w[0].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678), w[1].re, eps);

        try std.testing.expectApproxEqAbs( @as(T,  0.0       ), w[0].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678), w[1].im, eps);
    }


    inline for (.{f32, f64}) |T| {

        const C = Complex(T);
        const lut_type = LUTtype.long;

        const w = try lut(C, lut_type, allocator, n_fft);

        try std.testing.expectApproxEqAbs( @as(T,  1.0        ), w[0].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  1.0        ), w[1].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0        ), w[2].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  1.0        ), w[3].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.70710678 ), w[4].re, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0        ), w[5].re, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678 ), w[6].re, eps);

        try std.testing.expectApproxEqAbs( @as(T,  0.0        ), w[0].im, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0        ), w[1].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -1.0        ), w[2].im, eps);
        try std.testing.expectApproxEqAbs( @as(T,  0.0        ), w[3].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678 ), w[4].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -1.0        ), w[5].im, eps);
        try std.testing.expectApproxEqAbs( @as(T, -0.70710678 ), w[6].im, eps);
    }


}

