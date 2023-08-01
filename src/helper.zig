const std = @import("std");
const math = std.math;

pub inline fn absDiff(x: anytype, y: anytype) @TypeOf(x) {
    return if (x > y) (x - y) else (y - x);
}

pub inline fn intSaturateCast(comptime T: type, n: anytype) T {
    const max = math.maxInt(T);
    if (n > max) {
        return max;
    }

    const min = math.minInt(T);
    if (n < min) {
        return min;
    }

    return @as(T, @intCast(n));
}

pub inline fn floatSaturateCast(comptime T: type, n: anytype) T {
    const max = math.floatMax(T);
    if (n > max) {
        return max;
    }

    const min = math.floatMin(T);
    if (n < min) {
        return min;
    }

    return @as(T, @floatCast(n));
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
    return intSaturateCast(@TypeOf(x), result);
}

pub inline fn floatEuclideanDistance(x: anytype, y: anytype, z: anytype) @TypeOf(x) {
    @setFloatMode(.Optimized);
    return @sqrt(x * x + y * y + z * z);
}
