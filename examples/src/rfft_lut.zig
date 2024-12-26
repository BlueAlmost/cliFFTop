const std = @import("std");
const print = std.debug.print;

const math = std.math;
const Complex = std.math.Complex;

const cliFFTop = @import("cliFFTop_build_name");

const genData = cliFFTop.utils.genData;

pub fn main() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var n_rep: usize = undefined;
    var m: usize = undefined;
    if( (args.len != 3)) {
        print("error: call with two integer arguments:  n_rep (# of repetitions) and m (n_fft = 2^m)\n", .{});
        return;
    }
    else {
        n_rep = try std.fmt.parseInt(usize, args[1], 10);
        m = try std.fmt.parseInt(usize, args[2], 10);
    }

    const n_real: usize = math.shl(usize, 1, m);
    const n2: usize = n_real/2;

    const R = f64;
    const C: type = Complex(R);

    const x = try genData(R, allocator, n_real);
    const y = try allocator.alloc(C, n2+1);

    const w = try cliFFTop.luts.lut(C, cliFFTop.luts.LUTtype.full, allocator, n2);
    const w_edson = try cliFFTop.luts.lut(C, cliFFTop.luts.LUTtype.half, allocator, n_real);

    var i_rep: usize = 0;
    while(i_rep<n_rep): (i_rep+=1) {
        cliFFTop.ffts.rfft_lut(R, n_real, w, w_edson, y, x);
    }
}

