const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    // const optimize = b.standardOptimizeOption(.{.ReleaseFast});
    const optimize = std.builtin.OptimizeMode.ReleaseFast;

    const run_step = b.step("run", "Run the demo");
    const test_step = b.step("test", "Run unit tests");

    const targs = [_]Targ{
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
    };

    // build all targets
    for (targs) |targ| {
        targ.build(b, target, optimize, run_step, test_step);
    }
}

const Targ = struct {
    name: []const u8,
    src: []const u8,

    pub fn build(self: Targ, b: *std.Build, target: anytype, optimize: anytype, run_step: anytype, test_step: anytype) void {
        var exe = b.addExecutable(.{ .name = self.name, .root_source_file = .{ .path = self.src }, .target = target, .optimize = optimize });

        b.installArtifact(exe);

        b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{ .dest_dir = .{ .override = .{ .custom = "../bin" } } }).step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        run_step.dependOn(&run_cmd.step);

        const clifftop_dep = b.dependency("clifftop_zon_name", .{ // as declared in build.zig.zon
            .target = target,
            .optimize = optimize,
        });

        const clifftop_mod = clifftop_dep.module("clifftop_build_name"); // as declared in build.zig of dependency

        exe.root_module.addImport("clifftop_build_name", clifftop_mod); // name to use when importing

        _ = test_step;

        // const test_step = b.step("test", "Run unit tests");

        // const unit_tests = b.addTest(.{
        //     .root_source_file = .{ .path = self.src },
        //     .target = target,
        //     .optimize = optimize,
        // });

        // const run_unit_tests = b.addRunArtifact(unit_tests);
        // test_step.dependOn(&run_unit_tests.step);

        // const unit_tests = b.addTest(.{
        //     .root_source_file = .{ .path = self.src },
        //     .target = target,
        //     .optimize = optimize,
        // });

        // const run_unit_tests = b.addRunArtifact(unit_tests);
        // test_step.dependOn(&run_unit_tests.step);

    }
};
