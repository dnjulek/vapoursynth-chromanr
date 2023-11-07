const std = @import("std");
const math = std.math;

pub inline fn absDiff(x: anytype, y: anytype) @TypeOf(x) {
    return if (x > y) (x - y) else (y - x);
}

pub inline fn manhattanDistance(x: anytype, y: anytype, z: anytype) @TypeOf(x) {
    return (x + y + z);
}

pub inline fn intEuclideanDistance(x: anytype, y: anytype, z: anytype) @TypeOf(x) {
    @setFloatMode(.Optimized);
    const xf: f32 = @floatFromInt(x);
    const yf: f32 = @floatFromInt(y);
    const zf: f32 = @floatFromInt(z);
    const result: u32 = @intFromFloat(@sqrt((xf * xf) + (yf * yf) + (zf * zf)));
    return math.lossyCast(@TypeOf(x), result);
}

pub inline fn floatEuclideanDistance(x: anytype, y: anytype, z: anytype) @TypeOf(x) {
    @setFloatMode(.Optimized);
    return @sqrt(x * x + y * y + z * z);
}
