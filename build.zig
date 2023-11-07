const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "chromanr",
        .root_source_file = .{ .path = "src/chromanr.zig" },
        .target = target,
        .optimize = optimize,
    });

    const vapoursynth_dep = b.dependency("vapoursynth", .{
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("vapoursynth", vapoursynth_dep.module("vapoursynth"));
    lib.linkLibC();

    if (lib.optimize == .ReleaseFast) {
        lib.strip = true;
    }

    b.installArtifact(lib);
}
