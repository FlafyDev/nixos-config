import vapoursynth as vs
core = vs.core

core.std.LoadPlugin("@svpflow@libsvpflow1_vs64.so")
core.std.LoadPlugin("@svpflow@libsvpflow2_vs64.so")

clip = video_in

# FIXME: gpu 0 as rocm issues on amd

super_params     = "{scale:{up:0},gpu:0,rc:true}"
analyse_params   = "{block:{w:32},main:{search:{coarse:{type:2,distance:-6,bad:{sad:2000,range:24}},type:2}},refine:[{thsad:250}]}"
smoothfps_params = "{gpuid:11,gpu_qn:2,rate:{num:120,den:1,abs:true},algo:2,mask:{area:50},scene:{}}" # light:{aspect:2.389,lights:29,border:107,length:187,cell:5}

src_fps     = container_fps if container_fps>0.1 else 29.97
demo_mode   = 0
stereo_type = 0
nvof = 0

def interpolate(clip):
# input_um - original frame in 4:2:0
# input_m  - cropped and resized (if needed) frame
# input_m8 - input_m converted to 8-bit
    input_um = clip.resize.Point(format=vs.YUV420P8,dither_type="random")
    input_m = input_um
    input_m8 = input_m

    if nvof:
        smooth  = core.svp2.SmoothFps_NVOF(input_m,smoothfps_params,nvof_src=input_m8,src=input_um,fps=src_fps)
    else:
        super   = core.svp1.Super(input_m8,super_params)
        vectors = core.svp1.Analyse(super["clip"],super["data"],input_m8,analyse_params)
        smooth  = core.svp2.SmoothFps(input_m,super["clip"],super["data"],vectors["clip"],vectors["data"],smoothfps_params,src=input_um,fps=src_fps)

    if demo_mode==1:
        return demo(input_m,smooth)
    else:
        return smooth

if stereo_type == 1:
    lf = interpolate(core.std.CropRel(clip,0,(int)(clip.width/2),0,0))
    rf = interpolate(core.std.CropRel(clip,(int)(clip.width/2),0,0,0))
    smooth = core.std.StackHorizontal([lf, rf])
elif stereo_type == 2:
    lf = interpolate(core.std.CropRel(clip,0,0,0,(int)(clip.height/2)))
    rf = interpolate(core.std.CropRel(clip,0,0,(int)(clip.height/2),0))
    smooth = core.std.StackVertical([lf, rf])
else:
    smooth = interpolate(clip)

smooth.set_output()

