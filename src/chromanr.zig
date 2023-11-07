const std = @import("std");
const vs = @import("vapoursynth").vapoursynth4;

const math = std.math;
const ar = vs.ActivationReason;
const rp = vs.RequestPattern;
const fm = vs.FilterMode;
const st = vs.SampleType;
const cf = vs.ColorFamily;

const allocator = std.heap.c_allocator;

const int_process = @import("int_process.zig");
const helper = @import("helper.zig");

const ChromanrData = struct {
    node: ?*vs.Node,
    thres: u16,
    thres_y: u16,
    thres_u: u16,
    thres_v: u16,
    sizew: usize,
    sizeh: usize,
    stepw: usize,
    steph: usize,
    chroma_ssw: u6,
    chroma_ssh: u6,
    use_euclidean: bool,
    psize: u6,
};

export fn chromanrGetFrame(n: c_int, activation_reason: ar, instance_data: ?*anyopaque, frame_data: ?*?*anyopaque, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) ?*const vs.Frame {
    _ = frame_data;
    var d: *ChromanrData = @ptrCast(@alignCast(instance_data));

    if (activation_reason == ar.Initial) {
        vsapi.?.requestFrameFilter.?(n, d.node, frame_ctx);
    } else if (activation_reason == ar.AllFramesReady) {
        const src = vsapi.?.getFrameFilter.?(n, d.node, frame_ctx);
        var dst = vsapi.?.newVideoFrame.?(vsapi.?.getVideoFrameFormat.?(src), vsapi.?.getFrameWidth.?(src, 0), vsapi.?.getFrameHeight.?(src, 0), src, core);
        var srcpy: [*]const u8 = vsapi.?.getReadPtr.?(src, 0);
        var srcpu: [*]const u8 = vsapi.?.getReadPtr.?(src, 1);
        var srcpv: [*]const u8 = vsapi.?.getReadPtr.?(src, 2);
        var dstpy: [*]u8 = vsapi.?.getWritePtr.?(dst, 0);
        var dstpu: [*]u8 = vsapi.?.getWritePtr.?(dst, 1);
        var dstpv: [*]u8 = vsapi.?.getWritePtr.?(dst, 2);
        const stridey: usize = @intCast(vsapi.?.getStride.?(src, 0));
        const strideu: usize = @intCast(vsapi.?.getStride.?(src, 1));
        const stridev: usize = @intCast(vsapi.?.getStride.?(src, 2));
        const hy: usize = @intCast(vsapi.?.getFrameHeight.?(src, 0));
        const hu: usize = @intCast(vsapi.?.getFrameHeight.?(src, 1));
        const wu: usize = @intCast(vsapi.?.getFrameWidth.?(src, 1));

        const cssw: u6 = d.chroma_ssw;
        const cssh: u6 = d.chroma_ssh;
        const stepw: usize = d.stepw;
        const steph: usize = d.steph;
        const sizew: usize = d.sizew;
        const sizeh: usize = d.sizeh;
        const thres: u16 = d.thres;
        const thres_y: u16 = d.thres_y;
        const thres_u: u16 = d.thres_u;
        const thres_v: u16 = d.thres_v;
        const psize: u6 = d.psize;

        if (psize == 1) {
            int_process.process(
                u8,
                srcpy,
                srcpu,
                srcpv,
                dstpu,
                dstpv,
                stridey,
                strideu,
                stridev,
                wu,
                hu,
                cssw,
                cssh,
                thres,
                thres_y,
                thres_u,
                thres_v,
                sizew,
                sizeh,
                stepw,
                steph,
                d.use_euclidean,
            );
        } else {
            int_process.process(
                u16,
                srcpy,
                srcpu,
                srcpv,
                dstpu,
                dstpv,
                stridey,
                strideu,
                stridev,
                wu,
                hu,
                cssw,
                cssh,
                thres,
                thres_y,
                thres_u,
                thres_v,
                sizew,
                sizeh,
                stepw,
                steph,
                d.use_euclidean,
            );
        }

        @memcpy(dstpy[0..(stridey * hy)], srcpy);

        vsapi.?.freeFrame.?(src);
        return dst;
    }
    return null;
}

export fn chromanrFree(instance_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) void {
    _ = core;
    var d: *ChromanrData = @ptrCast(@alignCast(instance_data));
    vsapi.?.freeNode.?(d.node);
    allocator.destroy(d);
}

export fn chromanrCreate(in: ?*const vs.Map, out: ?*vs.Map, user_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) void {
    _ = user_data;
    var d: ChromanrData = undefined;
    var err: c_int = undefined;
    var _thres: f32 = undefined;
    var _threy: f32 = undefined;
    var _threu: f32 = undefined;
    var _threv: f32 = undefined;
    var _sizew: i64 = undefined;
    var _sizeh: i64 = undefined;
    var _stepw: i64 = undefined;
    var _steph: i64 = undefined;

    d.node = vsapi.?.mapGetNode.?(in, "clip", 0, &err).?;
    const vi: *const vs.VideoInfo = vsapi.?.getVideoInfo.?(d.node);
    d.chroma_ssw = @intCast(vi.format.subSamplingW);
    d.chroma_ssh = @intCast(vi.format.subSamplingH);

    _thres = math.lossyCast(f32, vsapi.?.mapGetFloat.?(in, "thres", 0, &err));
    if (err != 0) {
        _thres = 4.0;
    }

    _threy = math.lossyCast(f32, vsapi.?.mapGetFloat.?(in, "threy", 0, &err));
    if (err != 0) {
        _threy = 20.0;
    }

    _threu = math.lossyCast(f32, vsapi.?.mapGetFloat.?(in, "threu", 0, &err));
    if (err != 0) {
        _threu = 20.0;
    }

    _threv = math.lossyCast(f32, vsapi.?.mapGetFloat.?(in, "threv", 0, &err));
    if (err != 0) {
        _threv = 20.0;
    }

    _sizew = vsapi.?.mapGetInt.?(in, "sizew", 0, &err);
    if (err != 0) {
        d.sizew = 3;
    } else {
        d.sizew = math.lossyCast(usize, _sizew);
    }

    _sizeh = vsapi.?.mapGetInt.?(in, "sizeh", 0, &err);
    if (err != 0) {
        d.sizeh = 3;
    } else {
        d.sizeh = math.lossyCast(usize, _sizeh);
    }

    _stepw = vsapi.?.mapGetInt.?(in, "stepw", 0, &err);
    if (err != 0) {
        d.stepw = 1;
    } else {
        d.stepw = math.lossyCast(usize, _stepw);
    }

    _steph = vsapi.?.mapGetInt.?(in, "steph", 0, &err);
    if (err != 0) {
        d.steph = 1;
    } else {
        d.steph = math.lossyCast(usize, _steph);
    }

    var distance = vsapi.?.mapGetInt.?(in, "distance", 0, &err);
    d.use_euclidean = (distance == 1);
    if (err != 0) {
        d.use_euclidean = false;
    }

    d.psize = @as(u6, @intCast(vi.format.bytesPerSample));
    const depth: u5 = math.lossyCast(u5, vi.format.bitsPerSample - 8);
    const scal: f32 = @floatFromInt(@as(u32, 1) << depth);
    d.thres = @intFromFloat(_thres * scal);
    d.thres_y = @intFromFloat(_threy * scal);
    d.thres_u = @intFromFloat(_threu * scal);
    d.thres_v = @intFromFloat(_threv * scal);

    if (vi.format.colorFamily != cf.YUV) {
        vsapi.?.mapSetError.?(out, "chromanr: only works with YUV format");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if (vi.format.sampleType == st.Float) {
        vsapi.?.mapSetError.?(out, "chromanr: only works with int format");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if ((_thres < 1.0) or (_thres > 200.0) or (_threy < 1.0) or (_threy > 200.0) or
        (_threu < 1.0) or (_threu > 200.0) or (_threv < 1.0) or (_threv > 200.0))
    {
        vsapi.?.mapSetError.?(out, "chromanr: \"thres\", \"threy\", \"threu\" and \"threv\" must be between 1.0 and 200.0");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if ((d.sizew < 1) or (d.sizew > 100) or (d.sizeh < 1) or (d.sizeh > 100)) {
        vsapi.?.mapSetError.?(out, "chromanr: \"sizew\" and \"sizeh\" must be between 1 and 100");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if ((d.stepw < 1) or (d.stepw > 50) or (d.steph < 1) or (d.steph > 50)) {
        vsapi.?.mapSetError.?(out, "chromanr: \"stepw\" and \"steph\" must be between 1 and 50");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if ((distance < 0) or (distance > 1)) {
        vsapi.?.mapSetError.?(out, "chromanr: \"distance\" must be \"0\" (manhattan) or \"1\" (euclidean)");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if (d.stepw > d.sizew) {
        vsapi.?.mapSetError.?(out, "chromanr: \"stepw\" cannot be bigger than \"sizew\"");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    if (d.steph > d.sizeh) {
        vsapi.?.mapSetError.?(out, "chromanr: \"steph\" cannot be bigger than \"sizeh\"");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    var data: *ChromanrData = allocator.create(ChromanrData) catch unreachable;
    data.* = d;

    var deps = [_]vs.FilterDependency{
        vs.FilterDependency{
            .source = d.node,
            .requestPattern = rp.StrictSpatial,
        },
    };
    vsapi.?.createVideoFilter.?(out, "chromanr", vi, chromanrGetFrame, chromanrFree, fm.Parallel, &deps, 1, data, core);
}

export fn VapourSynthPluginInit2(plugin: *vs.Plugin, vspapi: *const vs.PLUGINAPI) void {
    _ = vspapi.configPlugin.?("com.julek.chromanr", "chromanr", "Chroma noise reduction", vs.makeVersion(1, 0), vs.VAPOURSYNTH_API_VERSION, 0, plugin);
    _ = vspapi.registerFunction.?(
        "CNR",
        "clip:vnode;thres:float:opt;threy:float:opt;threu:float:opt;threv:float:opt;sizew:int:opt;sizeh:int:opt;stepw:int:opt;steph:int:opt;distance:int:opt;",
        "clip:vnode;",
        chromanrCreate,
        null,
        plugin,
    );
}
