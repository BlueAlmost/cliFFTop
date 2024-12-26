const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    // const optimize = b.standardOptimizeOption(.{});

    const optimize: std.builtin.OptimizeMode = .ReleaseFast;

    const run_step = b.step("run", "Run the demo");
    const test_step = b.step("test", "Run unit tests");

    const targs = [_]Targ {
        .{
            .name = "reference",
            .src = "src/reference.zig",
        },
        .{
            .name = "cooley_tukey_inplace_wlong",
            .src = "src/cooley_tukey_inplace_wlong.zig",
        },
        .{
            .name = "cooley_tukey_recursive",
            .src = "src/cooley_tukey_recursive.zig",
        },
        .{
            .name = "mixed_radix",
            .src = "src/mixed_radix.zig",
        },
        .{
            .name = "rfft_no_lut",
            .src = "src/rfft_no_lut.zig",
        },
        .{
            .name = "rfft_lut",
            .src = "src/rfft_lut.zig",
        },
        .{
            .name = "rfft_sorensen_no_lut",
            .src = "src/rfft_sorensen_no_lut.zig",
        },
        .{
            .name = "rfft_sorensen_lut",
            .src = "src/rfft_sorensen_lut.zig",
        },
        .{
            .name = "fftw_zig",
            .src = "src/fftw_zig.zig",
            .link_fftw = true,
        },
    };

    // build all targets
    for (targs) |targ| {
        targ.build(b, target, optimize, run_step, test_step);
    }
}


const Targ = struct {
    name: []const u8,
    src: []const u8,
    link_fftw: bool = false,

    pub fn build(self: Targ, b: *std.Build, target: anytype, optimize: anytype, run_step: anytype, test_step: anytype) void {

        var exe = b.addExecutable(.{
            .name = self.name,
            .root_source_file = b.path(self.src),
            .target = target, 
            .optimize = optimize
        });

        if(self.link_fftw){
            exe.linkSystemLibrary("fftw3");
            exe.linkLibC();
        }

        b.installArtifact(exe);

        b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{
            .dest_dir = .{ .override = .{ .custom = "../bin"}}
        }).step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        run_step.dependOn(&run_cmd.step);

        const  cliFFTop_dep = b.dependency("cliFFTop_zon_name", .{ // as declared in build.zig.zon
            .target = target,
            .optimize = optimize,
        });

        const cliFFTop_mod = cliFFTop_dep.module("cliFFTop_build_name"); // as declared in build.zig of dependency

        exe.root_module.addImport("cliFFTop_build_name", cliFFTop_mod); // name to use when importing

        _ = test_step;

    }
};
