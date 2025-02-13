const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "verdis",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const cli_dep = b.dependency("cova", .{
        .target = target,
        .optimize = optimize,
    });
    const cli_mod = cli_dep.module("cova");

    exe.root_module.addImport("cova", cli_mod);

    b.installArtifact(exe);
}
