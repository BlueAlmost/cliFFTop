const std = @import("std");
const print = std.debug.print;

const math = std.math;
const Complex = std.math.Complex;

const clifftop = @import("clifftop_build_name");

const genData = clifftop.utils.genData;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var n_rep: usize = undefined;
    var m: usize = undefined;
    if ((args.len != 3)) {
        print("error: call with two integer arguments:  n_rep (# of repetitions) and m (n_fft = 2^m)\n", .{});
        std.os.exit(1);
    } else {
        n_rep = try std.fmt.parseInt(usize, args[1], 10);
        m = try std.fmt.parseInt(usize, args[2], 10);
    }

    const n_real: usize = math.shl(usize, 1, m);

    const R = f64;

    const x_orig = try genData(R, allocator, n_real);
    const x = try allocator.alloc(R, n_real);

    var i_rep: usize = 0;
    while (i_rep < n_rep) : (i_rep += 1) {
        @memcpy(x, x_orig);
        clifftop.ffts.rfft_sorensen_no_lut(R, n_real, x);
    }
}
