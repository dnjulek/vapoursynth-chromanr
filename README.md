# vapoursynth-chromanr

FFmpeg's chromanr for VapourSynth.\
This version is made with zig, if you have an nvidia GPU, check out the [cuda version](https://github.com/dnjulek/vapoursynth-chromanrcuda).

## Usage
```python
chromanr.CNR(vnode clip[, float thres=4, float threy=20, float threu=20, float threv=20 int sizew=1, int sizeh=1, int stepw=1, int steph=1, int distance=0])
```
### Parameters:

- clip\
    A YUV clip to process.
- thres\
    Set threshold for averaging chrominance values.\
    Sum of absolute difference of Y, U and V pixel components of current pixel and neighbour pixels lower than this threshold will be used in averaging.\
    Luma component is left unchanged and is copied to output.\
    Default value is 4. Allowed range is from 1 to 200.
- threy/threu/threu\
    Set Y/U/V threshold for averaging chrominance values.\
    Set finer control for max allowed difference between Y components of current pixel and neigbour pixels.\
    Default value is 20. Allowed range is from 1 to 200.
- sizew\
    Set horizontal radius of rectangle used for averaging.\
    Allowed range is from 1 to 100. Default value is 3.
- sizeh\
    Set vertical radius of rectangle used for averaging.\
    Allowed range is from 1 to 100. Default value is 3.
- stepw\
    Set horizontal step when averaging.\
    Mostly useful to speed-up filtering, if > 1 it will skip some columns in averaging.\
    Default value is 1. Allowed range is from 1 to 50.
- steph\
    Set vertical step when averaging.\
    Mostly useful to speed-up filtering, if > 1 it will skip some rows in averaging.\
    Default value is 1. Allowed range is from 1 to 50.
- distance\
    Set distance type used in calculations.\
    0 (manhattan): Absolute difference.\
    1 (euclidean): Difference squared.
## Building
Zig ver >= 0.11.0-dev.4333

``zig build -Doptimize=ReleaseFast``

If you don't have vapoursynth installed you must provide the include path with ``-Dvsinclude=...``.

## TODO
1. float support.
