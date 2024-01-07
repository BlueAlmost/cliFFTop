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
    const n_fft: usize = math.shl(usize, 1, m);

    const T = f64;
    const C: type = Complex(T);

    const x = try genData(C, allocator, n_fft);
    const y = try allocator.alloc(C, n_fft);

    const w = try clifftop.luts.lut(C, clifftop.luts.LUTtype.half, allocator, n_fft);

    var i_rep: usize = 0;
    while (i_rep < n_rep) : (i_rep += 1) {
        clifftop.ffts.cooley_tukey_recursive(C, n_fft, 1, w, y, x);
    }
}
