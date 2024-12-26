const std = @import("std");
const print= std.debug.print;

const math = std.math;
const Complex = std.math.Complex;

const fftw = @cImport({
    @cInclude("fftw3.h");
});

pub fn main() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var n_rep: usize = undefined;
    var m: usize = undefined;

    if(args.len != 3) {
        print("error: call with two integer arguments: n_rep (# of repetitions), m (n_fft = 2^m)\n", .{});
        return;
    }
    else {
        n_rep = try std.fmt.parseInt(usize, args[1], 10);
        m = try std.fmt.parseInt(usize, args[2], 10);
    }

    if(m>21) {
        print("excessive m value(maximum of 21), received m: {d}\n", .{m});
        return;
    }

    const n_real: i32 = math.shl(i32, 1, m);
    const n2 = @divFloor(n_real, 2);

    const R = f64;
    const C = Complex(R);

    const x = try allocator.alloc(R, @as(usize, @intCast(n_real)));
    const y = try allocator.alloc(C, @as(usize, @intCast(n2)));

    var i: usize = 0;
    while(i < n_real): (i += 1) {
        x[i] = @cos(0.946*2*math.pi*@as(R, @floatFromInt(i))/@as(R, @floatFromInt(n_real)));
        // print("x[{d}]: {d:8.4}\n", .{i, x[i]});
    }

    const y_ptr = @as([*c][2]f64, @ptrCast(y.ptr));
    const p = fftw.fftw_plan_dft_r2c_1d(n_real, x.ptr, y_ptr, fftw.FFTW_ESTIMATE);

    i = 0;
    while(i < n_rep): (i += 1) {
        fftw.fftw_execute(p);
    }

    // i = 0;
    // print("\n", .{});
    // while(i < n2): (i += 1) {
    //     print("y[{d}]: ({d:8.4}, {d:8.4})\n", .{i, y[i].re, y[i].im});
    // }
}

