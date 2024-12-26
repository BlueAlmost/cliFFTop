const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;
const print = std.debug.print;

pub fn ValueType(comptime T: type) type {
    switch (T) {
        f32, Complex(f32), []f32, []Complex(f32) => {
            return f32;
        },
        f64, Complex(f64), []f64, []Complex(f64) => {
            return f64;
        },
        else => {
            @compileError("type not implemented");
        },
    }
}


inline fn bitRev(i: anytype, n_width: usize) @TypeOf(i) {
    const T = @TypeOf(i);
    return math.shr(T, @bitReverse(i), @typeInfo(T).int.bits-n_width);
}

pub inline fn bitRevSwapBits(i: anytype, n_width: usize) @TypeOf(i) {

    // performs bit reversal, and then swaps bit in pairs
    const T = @TypeOf(i);

    const r = math.shr(T, @bitReverse(i), @typeInfo(T).int.bits-n_width);

    const evens: T = switch (T) {
        u8 => 0x55,
        u16 => 0x5555,
        u32 => 0x5555_5555,
        u64, usize => 0x5555_5555_5555_5555,
        else => @compileError("unexpected type"),
    };

    const odds: T = switch (T) {
        u8 => 0xaa,
        u16 => 0xaaaa,
        u32 => 0xaaaa_aaaa,
        u64, usize => 0xaaaa_aaaa_aaaa_aaaa,
        else => @compileError("unexpected type"),
    };

    return math.shl(T, (r & evens), 1) | math.shr(T, (r & odds), 1);

}


pub fn bitRevPermute(comptime T: type, n_width: usize, x: []T) void {

    const n = math.shl(usize, 1, n_width)-1;

    var i: usize = 0;
    var j: usize = undefined;

    while(i<n):(i+=1){

        j = bitRev(i, n_width);

        if(i<j){
            std.mem.swap(T, &x[i], &x[j]);
        }
    }
}

test "bitRev test" {

    inline for( .{u8, u16,  u32, u64}) |T| {

        const n_width: usize = 4;
        const n_width_str = std.fmt.comptimePrint("{d}", .{n_width});

        var r: T = undefined;

        const correct = [_]T { 0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15};

        for(correct, 0..)|val, idx| {
            const i: T = @intCast(idx);
            r = bitRev(i, n_width);
            _ = n_width_str;
            // print("i: {b:0>" ++ n_width_str ++ "}, r: {b:0>" ++ n_width_str ++ "}\n", .{i, r});
            try std.testing.expectEqual(val, r);
        }
    }
}
test "bitRevSwapBits test" {

    inline for( .{u8, u16,  u32, u64}) |T| {

        const n_width: usize = 4;
        const n_width_str = std.fmt.comptimePrint("{d}", .{n_width});

        var r: T = undefined;

        const correct = [_]T { 0, 4, 8, 12, 1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15};

        for(correct, 0..)|val, idx| {
            const i: T = @intCast(idx);
            r = bitRevSwapBits(i, n_width);
            _ = n_width_str;
            // print("i: {b:0>" ++ n_width_str ++ "}, r: {b:0>" ++ n_width_str ++ "}\n", .{i, r});
            print("i: {d}, r: {d}\n", .{i, r});
            try std.testing.expectEqual(val, r);
        }
    }
}

test "bitRevPermute test real" {

    inline for( .{u8, u16,  u32, u64}) |T| {

        const n_width: usize = 4;

        var x = [_]T{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
        const correct = [_]T { 0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15};

        bitRevPermute(T, n_width, &x);

        for(correct, 0..)|val, idx| {
            // print("correct: {d:5},  result: {d:5}\n", .{val, x[idx]});
            try std.testing.expectEqual(val, x[idx]);
        }
    }
}


test "bitRevPermute test complex" {

    inline for( .{f32, f64}) |T| {
        const C = Complex(T);

        const n_width: usize = 4;

        var x = [_]C{
            Complex(T).init( 0.0, 0.0),
            Complex(T).init( 1.0, 0.11),
            Complex(T).init( 2.0, 0.22),
            Complex(T).init( 3.0, 0.33),
            Complex(T).init( 4.0, 0.44),
            Complex(T).init( 5.0, 0.55),
            Complex(T).init( 6.0, 0.66),
            Complex(T).init( 7.0, 0.77),
            Complex(T).init( 8.0, 0.88),
            Complex(T).init( 9.0, 0.99),
            Complex(T).init(10.0, 0.10),
            Complex(T).init(11.0, 0.11),
            Complex(T).init(12.0, 0.12),
            Complex(T).init(13.0, 0.13),
            Complex(T).init(14.0, 0.14),
            Complex(T).init(15.0, 0.15),
        };

        const correct = [_]C{
            Complex(T).init( 0.0, 0.00),
            Complex(T).init( 8.0, 0.88),
            Complex(T).init( 4.0, 0.44),
            Complex(T).init(12.0, 0.12),
            Complex(T).init( 2.0, 0.22),
            Complex(T).init(10.0, 0.10),
            Complex(T).init( 6.0, 0.66),
            Complex(T).init(14.0, 0.14),
            Complex(T).init( 1.0, 0.11),
            Complex(T).init( 9.0, 0.99),
            Complex(T).init( 5.0, 0.55),
            Complex(T).init(13.0, 0.13),
            Complex(T).init( 3.0, 0.33),
            Complex(T).init(11.0, 0.11),
            Complex(T).init( 7.0, 0.77),
            Complex(T).init(15.0, 0.15),
        };


        bitRevPermute(C, n_width, &x);

        for(correct, 0..)|val, idx| {
            try std.testing.expectEqual(val.re, x[idx].re);
            try std.testing.expectEqual(val.im, x[idx].im);
        }
    }
}


pub fn genData(comptime T: type, allocator: std.mem.Allocator, n: usize) ![]T {

    var rnd = std.Random.DefaultPrng.init(42);
    const V = ValueType(T);
    var x = try allocator.alloc(T, n);

    switch(T) {

        f32, f64 => {
            for(x, 0..) |_, i| {
                x[i] = rnd.random().float(V) - 0.5;
            }
        },
        Complex(f32), Complex(f64) => {
            for(x, 0..) |_, i| {
                x[i].re = rnd.random().float(V) - 0.5;
                x[i].im = rnd.random().float(V) - 0.5;
            }
        },
        else => {
            @compileError("unexpected type");
        },
    }

    return x;
}



