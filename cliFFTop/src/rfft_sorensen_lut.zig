const std = @import("std");
const math = std.math;
const print = std.debug.print;

const utils = @import("utils");
const bitRevPermute = utils.bitRevPermute;

const sqrt1_2 = std.math.sqrt1_2;
const tau = std.math.tau;


pub fn soren_luts(comptime R: type, allocator: std.mem.Allocator, n: usize, s1: *[]R, s3: *[]R, c1: *[]R, c3: *[]R) !void {

    const n8 = n/8;

    s1.* = try allocator.alloc(R, n8);
    s3.* = try allocator.alloc(R, n8);
    c1.* = try allocator.alloc(R, n8);
    c3.* = try allocator.alloc(R, n8);


    const e: R = tau/@as(R, @floatFromInt(n));
    var a: R = e;

    var j: usize = 2;
    while(j <= n8):(j+=1){
        const a3: R = 3*a;

        s1.*[j-1] = @sin(a);
        s3.*[j-1] = @sin(a3);

        c1.*[j-1] = @cos(a);
        c3.*[j-1] = @cos(a3);

        a = e * @as(R, @floatFromInt(j));
    }
}





pub fn rsrfft(comptime R: type, n: usize, x: []R, s1: []R, s3: []R, c1: []R, c3: []R) void {

    std.debug.assert(x.len == 8*s1.len);

    const m: usize = math.log2(n);

    bitRevPermute(R, m, x[0..n]);

    // length 2 butterflies ------------------------------------------------------
    var is: usize = 1;
    var id: usize = 4;

    while(is<n) {  
        var i: usize = is;
        while(i < n ):(i += id) {
            const t1: R = x[i-1];
            x[i-1]    = t1 + x[i];
            x[i]      = t1 - x[i];
        }
        is = 2*id-1;
        id = 4*id;
    }

    // L shaped butterflies ------------------------------------------------------

    var n2: usize = 2;
    var k:  usize = 2;
    while(k<=m):(k+=1){

        n2 = n2*2;
        rstage(R, n, n2, @constCast(x), s1, s3, c1, c3);

    }
}



pub fn rstage(comptime R: type, n: usize, n2: usize, x: []R, s1: []R, s3: []R, c1: []R, c3: []R) void {

    const n4 = n2/4;
    const n8: usize = n2/8;
    const lut_stride: usize = n/n2;

    const x1 = x[0..];
    const x2 = x[n4..];
    const x3 = x[(2*n4)..];
    const x4 = x[(3*n4)..];

    var is: usize = 0;
    var id: usize = n2*2;

    while(is < n) {
        var i_1: usize = is;
        while(i_1 < n):(i_1 += id) {
            const t1: R = x4[i_1] + x3[i_1];
            x4[i_1] = x4[i_1] - x3[i_1];
            x3[i_1] = x1[i_1] - t1;
            x1[i_1] = x1[i_1] + t1;
        }
        is = 2*id - n2;
        id = 4*id;
    }

    if((n4-1)<=0) return;

    is = 0;
    id = n2*2;

    while(is < n) {
        var i_2 = is+n8;
        while(i_2 < n):(i_2 += id){

            const t1: R = sqrt1_2 * (x3[i_2] + x4[i_2]);
            const t2: R = sqrt1_2 * (x3[i_2] - x4[i_2]);

            x4[i_2] =  x2[i_2] - t1;
            x3[i_2] = -x2[i_2] - t1;
            x2[i_2] =  x1[i_2] - t2;
            x1[i_2] =  x1[i_2] + t2;

        }
        is = 2*id - n2;
        id = 4*id;
    }

    if((n8-1)<=0) return;

    var j: usize = 2;

    while(j<=n8):(j+=1){

        const lut_idx: usize = (j-1)*lut_stride;

        is = 0;
        id = 2 * n2;
        const jn: usize = n4 - 2*j + 2;
        var t1: R = undefined;
        var t3: R = undefined;

        while(is < n){

            var i_1 = is + j - 1;
            while(i_1 < n-1):(i_1 += id){
                const i_2: usize = i_1 + jn;

                t1       = x3[i_1]*c1[lut_idx] + x3[i_2]*s1[lut_idx];

                const t2 = x3[i_2]*c1[lut_idx] - x3[i_1]*s1[lut_idx];
                t3       = x4[i_1]*c3[lut_idx] + x4[i_2]*s3[lut_idx];
                var t4   = x4[i_2]*c3[lut_idx] - x4[i_1]*s3[lut_idx];

                const t5 = t1 + t3;
                t3 = t1 - t3;
                t1 = t2 + t4;
                t4 = t2 - t4;

                x3[i_1] = t1 - x2[i_2];
                x4[i_2] = t1 + x2[i_2];
                x3[i_2] = -x2[i_1] - t3;
                x4[i_1] =  x2[i_1] - t3;

                x2[i_2] = x1[i_1] - t5;
                x1[i_1] = x1[i_1] + t5;
                x2[i_1] = x1[i_2] + t4;
                x1[i_2] = x1[i_2] - t4;

            }

            is = 2*id - n2;
            id = 4*id;
        }
    }
}

