const std = @import("std");
const print = std.debug.print;

const math = std.math;
const Complex = std.math.Complex;

const complex_math = @import("complex_math");
const add = complex_math.add;
const sub = complex_math.sub;
const mul = complex_math.mul;

const utils = @import("utils");
const ValueType = utils.ValueType;

// reference fft implmentation
pub fn fft(comptime C: type, size: usize, out: []C, in: []C, stride: usize) void {

    const V = ValueType(C);

    const half: usize = size >> 1;

    if (half == 0) {
        out[0] = in[0];
    } else {
        fft(C, half, out, in, stride << 1);
        fft(C, half, out[half..], in[stride..], stride << 1);

        var i: usize = 0;
        while (i < half) : (i += 1) {
            const a: C = out[i];
            const b: C = out[i + half];

            const angle: V = 2 * math.pi * @as(V, @floatFromInt(i)) / @as(V, @floatFromInt(size));
            var tw: C = undefined;

            tw.re = @cos(angle);
            tw.im = -@sin(angle);

            const c: C = mul(b, tw);
            out[i] = add(a, c);
            out[i + half] = sub(a, c);
        }
    }
}


test "reference fft testing - complex" {

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const nfft: usize = 16;

    inline for (.{f32, f64}) |T| {

        const C: type = Complex(T);
        var eps: T = undefined;

        switch(T){
            f32 => { eps = 1e-6; },
            f64 => { eps = 1e-14; },
            else => { @compileError("unexpected type"); },
        }

        var x = try allocator.alloc(C, nfft);
        const y = try allocator.alloc(C, nfft);
        var y_ref = try allocator.alloc(C, nfft);

        x[ 0] = C.init(  1.5253989004340944 , 0.15844498542090418   );
        x[ 1] = C.init( -0.32894316005753504, 0.576517303267065     );
        x[ 2] = C.init( -0.22671367721994665, -0.9885457534509109   );
        x[ 3] = C.init(  0.18663729666477344, -0.7585242940257791   );
        x[ 4] = C.init( -0.5897707133224489 , -0.13803574004797622  );
        x[ 5] = C.init( -0.3780329032156028 , -0.29638007437054126  );
        x[ 6] = C.init( -1.5497638277066752 , 0.3711691648075596    );
        x[ 7] = C.init( -0.966109466244281  , 0.3938135923752739    );
        x[ 8] = C.init(  1.7515204122388293 , 0.4399391113159247    );
        x[ 9] = C.init(  1.05078993000288   , -0.774437846395909    );
        x[10] = C.init( -0.47953716746448977, -0.042216932952725564 );
        x[11] = C.init( -0.06550966229332986, -1.1613248152516427   );
        x[12] = C.init(  0.413723498989494  , 0.4451150501140974    );
        x[13] = C.init( -1.6498655535481366 , -0.19743614855429478  );
        x[14] = C.init(  0.5709979685383257 , -0.6442496366623515   );
        x[15] = C.init( -0.0653047079086655 , 1.8045889836496902    );

        y_ref[ 0] = C.init( -0.8004828321127149 , -0.811563050761616   );
        y_ref[ 1] = C.init(  0.34310571429539627, 2.8639329736798347   );
        y_ref[ 2] = C.init(  1.1218638287870681 , 0.3807296824546511   );
        y_ref[ 3] = C.init( -0.6852537591055646 , 4.706469637762485    );
        y_ref[ 4] = C.init(  3.815598569391532  , 2.60507171209827     );
        y_ref[ 5] = C.init( -3.466840931572275  , 2.885160181364263    );
        y_ref[ 6] = C.init(  0.3784415220192969 , -5.316787358613111   );
        y_ref[ 7] = C.init(  3.07707711356334   , -7.271750353461281   );
        y_ref[ 8] = C.init(  3.63219362108708   , 0.014803547850659293 );
        y_ref[ 9] = C.init(  1.4928141734880418 , -1.5525992077643669  );
        y_ref[10] = C.init(  4.2687047961269995 , -0.34315013808106176 );
        y_ref[11] = C.init( -1.8597361996681858 , -1.8604525352138905  );
        y_ref[12] = C.init(  5.756179034993977  , 1.8135414180244875   );
        y_ref[13] = C.init( -1.6061681640783974 , -1.308493601612041   );
        y_ref[14] = C.init(  8.042855961090149  , 6.444426960922353    );
        y_ref[15] = C.init(  0.8960299586397652 , -0.714220101915169   );

        // fft(C, nfft, y.ptr, x.ptr, 1);
        fft(C, nfft, y, x, 1);

        for(y_ref, 0..)|val, i| {
            try std.testing.expectApproxEqAbs( val.re, y[i].re, eps);
            try std.testing.expectApproxEqAbs( val.im, y[i].im, eps);
        }
    }

}

test "reference fft testing - real" {

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const nfft: usize = 16;

    inline for (.{f32, f64}) |T| {

        const C: type = Complex(T);
        var eps: T = undefined;

        switch(T){
            f32 => { eps = 1e-6; },
            f64 => { eps = 1e-14; },
            else => { @compileError("unexpected type"); },
        }

        var x = try allocator.alloc(C, nfft);
        const y = try allocator.alloc(C, nfft);


        // var y_ref = try allocator.alloc(C, 1+nfft/2);
        var y_ref = try allocator.alloc(C, nfft);


        x[ 0] = C.init(  0.501323986460705  , 0.0 );
        x[ 1] = C.init(  0.3603873445006252 , 0.0 );
        x[ 2] = C.init( -0.6416592277288763 , 0.0 );
        x[ 3] = C.init(  0.2573131825962977 , 0.0 );
        x[ 4] = C.init( -0.06881473388913668, 0.0 );
        x[ 5] = C.init( -0.42026822174436246, 0.0 );
        x[ 6] = C.init( -0.6994668046768233 , 0.0 );
        x[ 7] = C.init( -1.255788322610742  , 0.0 );
        x[ 8] = C.init(  1.2302872383213517 , 0.0 );
        x[ 9] = C.init( -1.9328510650064388 , 0.0 );
        x[10] = C.init(  1.469935395790503  , 0.0 );
        x[11] = C.init( -0.5158531668351386 , 0.0 );
        x[12] = C.init(  0.24767010682657992, 0.0 );
        x[13] = C.init( -1.6917754287514528 , 0.0 );
        x[14] = C.init( -0.931759850529731  , 0.0 );
        x[15] = C.init(  0.18056122599778396, 0.0 );

        y_ref[ 0] = C.init( -3.9107583412788554, 0.0                 );
        y_ref[ 1] = C.init(  0.8686410721254187, -0.5715974897264242 );
        y_ref[ 2] = C.init(  1.356811484065308 , -3.418528446023672  );
        y_ref[ 3] = C.init(  2.8160740531394794, 1.0031826631697833  );
        y_ref[ 4] = C.init(  2.7134170848644272, 2.35074029014983    );
        y_ref[ 5] = C.init( -0.9592428261554197, -1.0215814343238625 );
        y_ref[ 6] = C.init(  1.7487002196239188, 1.5004772005126898  );
        y_ref[ 7] = C.init( -5.641325306552066 , -3.862300950082936  );
        y_ref[ 8] = C.init(  6.125790562428    , 0.0                 );
        y_ref[ 9] = C.init( -5.641325306552066 , 3.862300950082936   );
        y_ref[10] = C.init(  1.7487002196239188, -1.5004772005126898 );
        y_ref[11] = C.init( -0.9592428261554197, 1.0215814343238625  );
        y_ref[12] = C.init(  2.7134170848644272, -2.35074029014983   );
        y_ref[13] = C.init(  2.8160740531394794, -1.0031826631697833 );
        y_ref[14] = C.init(  1.356811484065308 , 3.418528446023672   );
        y_ref[15] = C.init(  0.8686410721254187, 0.5715974897264242  );

        fft(C, nfft, y, x, 1);

        for(y_ref, 0..)|val, i| {
            try std.testing.expectApproxEqAbs( val.re, y[i].re, eps);
            try std.testing.expectApproxEqAbs( val.im, y[i].im, eps);
        }
    }

}

