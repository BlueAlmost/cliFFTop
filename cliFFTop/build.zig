const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //--------------------------------------------------------------------------
    const complex_math = b.addModule("complex_math", .{
        .root_source_file = b.path ("./src/complex_math.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = complex_math;

    const complex_math_tests = b.addTest(.{
        .root_source_file = b.path ("src/complex_math.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_complex_math_tests = b.addRunArtifact(complex_math_tests);

    //--------------------------------------------------------------------------
    const utils = b.addModule("utils", .{
        .root_source_file = b.path ("src/utils.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = utils;

    const utils_tests = b.addTest(.{
        .root_source_file = b.path ("src/utils.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_utils_tests = b.addRunArtifact(utils_tests);

    //--------------------------------------------------------------------------

    const luts = b.addModule("luts", .{
        .root_source_file = b.path ("src/luts.zig"),
        .target = target,
        .optimize = optimize,
    });
    luts.addImport("utils", b.modules.get("utils").?);

    const luts_tests = b.addTest(.{
        .root_source_file = b.path ("src/luts.zig"),
        .target = target,
        .optimize = optimize,
    });
    luts_tests.root_module.addImport("utils", b.modules.get("utils").?);
    const run_luts_tests = b.addRunArtifact(luts_tests);


    //--------------------------------------------------------------------------
    const butterflies = b.addModule("butterflies", .{
        .root_source_file = b.path ("src/butterflies.zig"),
        .target = target,
        .optimize = optimize,
    });
    butterflies.addImport("complex_math", b.modules.get("complex_math").?);
    butterflies.addImport("utils", b.modules.get("utils").?);

    const butterflies_tests = b.addTest(.{
        .root_source_file = b.path ("src/butterflies.zig"),
        .target = target,
        .optimize = optimize,
    });
    butterflies_tests.root_module.addImport("complex_math", b.modules.get("complex_math").?);
    butterflies_tests.root_module.addImport("utils", b.modules.get("utils").?);
    const run_butterflies_tests = b.addRunArtifact(butterflies_tests);

    //--------------------------------------------------------------------------
    const reference_fft = b.addModule("reference_fft", .{
        .root_source_file = b.path ("src/reference_fft.zig"),
        .target = target,
        .optimize = optimize,
    }
    
    );
    reference_fft.addImport("complex_math", b.modules.get("complex_math").?);
    reference_fft.addImport("utils", b.modules.get("utils").?);

    const reference_fft_tests = b.addTest(.{
        .root_source_file = b.path ("src/reference_fft.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    reference_fft_tests.root_module.addImport("utils", b.modules.get("utils").?);
    reference_fft_tests.root_module.addImport("complex_math", b.modules.get("complex_math").?);
    
    const run_reference_fft_tests = b.addRunArtifact(reference_fft_tests);

    //--------------------------------------------------------------------------
    const ffts = b.addModule("ffts", .{
        .root_source_file = b.path ("src/ffts.zig"),
        .target = target,
        .optimize = optimize,
    });
    ffts.addImport("complex_math", b.modules.get("complex_math").?);
    ffts.addImport("utils", b.modules.get("utils").?);
    ffts.addImport("luts", b.modules.get("luts").?);
    ffts.addImport("butterflies", b.modules.get("butterflies").?);

    const ffts_tests = b.addTest(.{
        .root_source_file = b.path ("src/ffts.zig"),
        .target = target,
        .optimize = optimize,
    });
    ffts_tests.root_module.addImport("reference_fft", b.modules.get("reference_fft").?);
    ffts_tests.root_module.addImport("complex_math", b.modules.get("complex_math").?);
    ffts_tests.root_module.addImport("utils", b.modules.get("utils").?);
    ffts_tests.root_module.addImport("luts", b.modules.get("luts").?);
    ffts_tests.root_module.addImport("butterflies", b.modules.get("butterflies").?);
    const run_ffts_tests = b.addRunArtifact(ffts_tests);

    //--------------------------------------------------------------------------
    const cliFFTop = b.addModule("cliFFTop_build_name", .{
        .root_source_file = b.path ("cliFFTop.zig"),
        .target = target,
        .optimize = optimize,
    });
    cliFFTop.addImport("reference_fft", b.modules.get("reference_fft").?);
    cliFFTop.addImport("complex_math", b.modules.get("complex_math").?);
    cliFFTop.addImport("utils", b.modules.get("utils").?);
    cliFFTop.addImport("luts", b.modules.get("luts").?);
    cliFFTop.addImport("butterflies", b.modules.get("butterflies").?);
    cliFFTop.addImport("ffts", b.modules.get("ffts").?);
    
    const cliFFTop_tests = b.addTest(.{
        .root_source_file = b.path ("cliFFTop.zig"),
        .target = target,
        .optimize = optimize,
    });

    cliFFTop_tests.root_module.addImport("reference_fft", b.modules.get("reference_fft").?);
    cliFFTop_tests.root_module.addImport("complex_math", b.modules.get("complex_math").?);
    cliFFTop_tests.root_module.addImport("utils", b.modules.get("utils").?);
    cliFFTop_tests.root_module.addImport("luts", b.modules.get("luts").?);
    cliFFTop_tests.root_module.addImport("butterflies", b.modules.get("butterflies").?);
    cliFFTop_tests.root_module.addImport("ffts", b.modules.get("ffts").?);
    const run_cliFFTop_tests = b.addRunArtifact(cliFFTop_tests);


    const test_step = b.step("test", "Run module tests");
    test_step.dependOn(&run_complex_math_tests.step);
    test_step.dependOn(&run_utils_tests.step);
    test_step.dependOn(&run_luts_tests.step);
    test_step.dependOn(&run_butterflies_tests.step);
    test_step.dependOn(&run_reference_fft_tests.step);
    test_step.dependOn(&run_ffts_tests.step);
    test_step.dependOn(&run_cliFFTop_tests.step);

}


