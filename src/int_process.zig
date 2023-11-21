const std = @import("std");
const math = std.math;

const helper = @import("helper.zig");

pub inline fn process(
    comptime T: type,
    srcpy: [*]const u8,
    srcpu: [*]const u8,
    srcpv: [*]const u8,
    dstpu: [*]u8,
    dstpv: [*]u8,
    stridey: usize,
    strideu: usize,
    stridev: usize,
    w: usize,
    h: usize,
    cssw: u6,
    cssh: u6,
    thres: u16,
    thres_y: u16,
    thres_u: u16,
    thres_v: u16,
    sizew: usize,
    sizeh: usize,
    stepw: usize,
    steph: usize,
    use_euclidean: bool,
) void {
    var out_uptr: [*]T = @ptrCast(@alignCast(dstpu));
    var out_vptr: [*]T = @ptrCast(@alignCast(dstpv));

    var distance: u32 = undefined;
    var x: usize = undefined;
    var y: usize = 0;

    while (y < h) : (y += 1) {
        const in_yptr: [*]const T = @ptrCast(@alignCast(srcpy + ((stridey * y) << cssh)));
        const in_uptr: [*]const T = @ptrCast(@alignCast(srcpu + strideu * y));
        const in_vptr: [*]const T = @ptrCast(@alignCast(srcpv + stridev * y));
        const yystart: usize = y -| sizeh;
        const yystop: usize = @min(h - 1, y + sizeh);
        x = 0;
        while (x < w) : (x += 1) {
            const xxstart: usize = x -| sizew;
            const xxstop: usize = @min(w - 1, x + sizew);
            const cy: T = in_yptr[x << cssw];
            const cu: T = in_uptr[x];
            const cv: T = in_vptr[x];

            var su: u32 = cu;
            var sv: u32 = cv;
            var cn: u32 = 1;
            var yy = yystart;

            while (yy <= yystop) : (yy += steph) {
                const in_yptr2: [*]const T = @ptrCast(@alignCast(srcpy + ((stridey * yy) << cssh)));
                const in_uptr2: [*]const T = @ptrCast(@alignCast(srcpu + strideu * yy));
                const in_vptr2: [*]const T = @ptrCast(@alignCast(srcpv + stridev * yy));

                var xx = xxstart;
                while (xx <= xxstop) : (xx += stepw) {
                    const Y: T = in_yptr2[xx << cssw];
                    const U: T = in_uptr2[xx];
                    const V: T = in_vptr2[xx];
                    const cyY: u32 = helper.absDiff(cy, Y);
                    const cuU: u32 = helper.absDiff(cu, U);
                    const cvV: u32 = helper.absDiff(cv, V);
                    if (use_euclidean) {
                        distance = helper.intEuclideanDistance(cyY, cuU, cvV);
                    } else {
                        distance = helper.manhattanDistance(cyY, cuU, cvV);
                    }

                    if ((distance < thres) and
                        (cuU < thres_u) and
                        (cvV < thres_v) and
                        (cyY < thres_y))
                    {
                        su += U;
                        sv += V;
                        cn += 1;
                    }
                }
            }

            out_uptr[x] = @intCast((su + (cn >> 1)) / cn);
            out_vptr[x] = @intCast((sv + (cn >> 1)) / cn);
        }
        out_uptr += strideu / @sizeOf(T);
        out_vptr += stridev / @sizeOf(T);
    }
}
