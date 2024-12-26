const std = @import("std");
const math = std.math;
const print = std.debug.print;

const utils = @import("utils");
const bitRevPermute = utils.bitRevPermute;

const sqrt1_2 = std.math.sqrt1_2;
const tau = std.math.tau;

pub fn rsrfft(comptime R: type, n: usize, x: []R) void {
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
        rstage(R, n, n2, x);

    }
}



pub fn rstage(comptime R: type, n: usize, n2: usize, x: []R) void {

    const n4 = n2/4;
    const n8: usize = n2/8;

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

    const e: R = tau/@as(R, @floatFromInt(n2));

    const sd1: R = @sin(e);
    const sd3: R = 3*sd1 - 4*sd1*sd1*sd1;

    var ss1: R = sd1;
    var ss3: R = sd3;

    const cd1: R = @cos(e);
    const cd3: R = 4*cd1*cd1*cd1 - 3*cd1;

    var cc1: R = cd1;
    var cc3: R = cd3;

    var j: usize = 2;

    while(j<=n8):(j+=1){
        is = 0;
        id = 2 * n2;
        const jn: usize = n4 - 2*j + 2;
        var t1: R = undefined;
        var t3: R = undefined;

        while(is < n){

            var i_1 = is + j - 1;
            while(i_1 < n-1):(i_1 += id){
                const i_2: usize = i_1 + jn;

                t1 = x3[i_1]*cc1 + x3[i_2]*ss1;

                const t2 = x3[i_2]*cc1 - x3[i_1]*ss1;
                t3 = x4[i_1]*cc3 + x4[i_2]*ss3;
                var t4 = x4[i_2]*cc3 - x4[i_1]*ss3;

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

        t1  = cc1*cd1 - ss1*sd1;
        ss1 = cc1*sd1 + ss1*cd1;
        cc1 = t1;

        t3  = cc3*cd3 - ss3*sd3;
        ss3 = cc3*sd3 + ss3*cd3;
        cc3 = t3;

    }
}

