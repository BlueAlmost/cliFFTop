const std = @import("std");
const Complex = std.math.Complex;

const reference_fft = @import("reference_fft").fft;
const utils = @import("utils");
const luts = @import("luts");
const eps = 1e-5;


pub const cooley_tukey_inplace_wlong = @import("cooley_tukey_inplace_wlong.zig").fft;

test "cooley_tukey_inplace_wlong" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\ncooley_tukey_inplace_wlong:\n", .{});
    inline for (.{f32, f64}) |T| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{T, n_fft});

            const C = Complex(T);

            const x = try utils.genData(C, allocator, n_fft);
            const y_ref = try allocator.alloc(C, n_fft);
            reference_fft(C, n_fft, y_ref, x, 1);

            const w = try luts.lut(C, luts.LUTtype.long, allocator, n_fft);

            cooley_tukey_inplace_wlong(C, n_fft, w, x);

            for(y_ref, 0..)|val, i| {
                try std.testing.expectApproxEqAbs( val.re, x[i].re, eps);
                try std.testing.expectApproxEqAbs( val.im, x[i].im, eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}



pub const mixed_radix = @import("mixed_radix.zig").fft;

test "mixed radix" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\nmixed_radix:\n", .{});
    inline for (.{f32, f64}) |T| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{T, n_fft});

            const C = Complex(T);

            const x = try utils.genData(C, allocator, n_fft);
            const y_ref = try allocator.alloc(C, n_fft);
            reference_fft(C, n_fft, y_ref, x, 1);

            const w = try luts.lut(C, luts.LUTtype.full, allocator, n_fft);
            const y = try allocator.alloc(C, n_fft);

            mixed_radix(C, n_fft, w, y, x);

            for(y_ref, 0..)|val, i| {
                try std.testing.expectApproxEqAbs( val.re, y[i].re, eps);
                try std.testing.expectApproxEqAbs( val.im, y[i].im, eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}



pub const cooley_tukey_recursive = @import("cooley_tukey_recursive.zig").fft;

test "cooley_tukey_recursive" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\ncooley_tukey_recursive:\n", .{});
    inline for (.{f32, f64}) |T| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{T, n_fft});

            const C = Complex(T);

            const x = try utils.genData(C, allocator, n_fft);
            const y_ref = try allocator.alloc(C, n_fft);
            reference_fft(C, n_fft, y_ref, x, 1);

            const w = try luts.lut(C, luts.LUTtype.half, allocator, n_fft);
            const y = try allocator.alloc(C, n_fft);
            cooley_tukey_recursive(C, n_fft, 1, w, y, x);

            for(y_ref, 0..)|val, i| {
                try std.testing.expectApproxEqAbs( val.re, y[i].re, eps);
                try std.testing.expectApproxEqAbs( val.im, y[i].im, eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}




pub const rfft_no_lut = @import("rfft_no_lut.zig").rfft;

test "rfft_no_lut" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\nrfft_no_lut:\n", .{});
    inline for (.{f32, f64}) |R| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{R, n_fft});

            const n_real: usize = std.math.shl(usize, 1, m);
            const n2: usize = n_real/2;

            const C = Complex(R);

            const x_real = try utils.genData(R, allocator, n_real);
            var x_cmpx = try allocator.alloc(C, n_real);

            for(x_real, 0..) |val, i| {
                x_cmpx[i].re = val;
                x_cmpx[i].im = 0;
            }

            const y_ref = try allocator.alloc(C, n_real);
            reference_fft(C, n_real, y_ref, x_cmpx, 1);

            const w = try luts.lut(C, luts.LUTtype.full, allocator, n2);
            const y = try allocator.alloc(C, n2+1);

            rfft_no_lut(R, n_real, w, y, x_real);

            var i: usize = 0;
            while(i<n2+1):(i+=1){
                try std.testing.expectApproxEqAbs( y_ref[i].re, y[i].re, eps);
                try std.testing.expectApproxEqAbs( y_ref[i].im, y[i].im, eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}



pub const rfft_lut = @import("rfft_lut.zig").rfft;

test "rfft_lut" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\nrfft_lut:  \n", .{});
    inline for (.{f32, f64}) |R| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{R, n_fft});

            const n_real: usize = std.math.shl(usize, 1, m);
            const n2: usize = n_real/2;

            const C = Complex(R);

            const x_real = try utils.genData(R, allocator, n_real);
            var x_cmpx = try allocator.alloc(C, n_real);

            for(x_real, 0..) |val, i| {
                x_cmpx[i].re = val;
                x_cmpx[i].im = 0;
            }

            const y_ref = try allocator.alloc(C, n_real);
            reference_fft(C, n_real, y_ref, x_cmpx, 1);

            // note, complex fft size is n_real/2, 
            //
            // w is a "full lut type", on the complex, so w.len = n_real/2
            // w_edson is a "half lut type", on the real, so w_edson.len = n_real/2


            const w = try luts.lut(C, luts.LUTtype.full, allocator, n2);
            const w_edson = try luts.lut(C, luts.LUTtype.half, allocator, n_real);

            const y = try allocator.alloc(C, n2+1);

            rfft_lut(R, n_real, w, w_edson, y, x_real);

            var i: usize = 0;
            while(i<n2+1):(i+=1){
                try std.testing.expectApproxEqAbs( y_ref[i].re, y[i].re, eps);
                try std.testing.expectApproxEqAbs( y_ref[i].im, y[i].im, eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}



pub const rfft_sorensen_no_lut = @import("rfft_sorensen_no_lut.zig").rsrfft;

test "rfft_sorensen_no_lut" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\nrfft_sorensen_no_lut:\n", .{});
    inline for (.{f32, f64}) |R| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{R, n_fft});

            const n_real: usize = std.math.shl(usize, 1, m);
            const n2: usize = n_real/2;

            const C = Complex(R);

            const x_real = try utils.genData(R, allocator, n_real);
            var x_cmpx = try allocator.alloc(C, n_real);

            for(x_real, 0..) |val, idx| {
                x_cmpx[idx].re = val;
                x_cmpx[idx].im = 0;
            }

            const y_ref = try allocator.alloc(C, n_real);
            reference_fft(C, n_real, y_ref, x_cmpx, 1);

            rfft_sorensen_no_lut(R, n_real, x_real);

            var i: usize = 0;
            // verify real components
            while(i<n2+1):(i+=1){
                try std.testing.expectApproxEqAbs( y_ref[i].re, x_real[i], eps);
            }

            // verify imaginary components
            i = 1;
            while(i<=n2-1):(i+=1) {
                try std.testing.expectApproxEqAbs( y_ref[i].im, x_real[n_real-i], eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}

pub const rfft_sorensen_lut = @import("rfft_sorensen_lut.zig").rsrfft;
pub const soren_luts = @import("rfft_sorensen_lut.zig").soren_luts;

test "rfft_sorensen_lut" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("\nrfft_sorensen_lut:\n", .{});
    inline for (.{f32, f64}) |R| {
        inline for (.{4, 5, 6, 7}) |m| {
            const n_fft: usize = std.math.shl(usize, 1, m);
            std.debug.print("type: {any}, n_fft: {d:6}\n", .{R, n_fft});

            const n_real: usize = std.math.shl(usize, 1, m);
            const n2: usize = n_real/2;

            const C = Complex(R);

            const x_real = try utils.genData(R, allocator, n_real);
            var x_cmpx = try allocator.alloc(C, n_real);

            for(x_real, 0..) |val, idx| {
                x_cmpx[idx].re = val;
                x_cmpx[idx].im = 0;
            }

            const y_ref = try allocator.alloc(C, n_real);
            reference_fft(C, n_real, y_ref, x_cmpx, 1);

            var s1: []R = undefined;
            var s3: []R = undefined;
            var c1: []R = undefined;
            var c3: []R = undefined;

            try soren_luts(R, allocator, n_real, &s1, &s3, &c1, &c3);

            rfft_sorensen_lut(R, n_real, x_real, s1, s3, c1, c3);

            var i: usize = 0;
            // verify real components
            while(i<n2+1):(i+=1){
                try std.testing.expectApproxEqAbs( y_ref[i].re, x_real[i], eps);
            }

            // verify imaginary components
            i = 1;
            while(i<=n2-1):(i+=1) {
                try std.testing.expectApproxEqAbs( y_ref[i].im, x_real[n_real-i], eps);
            }
        }
    std.debug.print(" \n", .{});
    }
}


