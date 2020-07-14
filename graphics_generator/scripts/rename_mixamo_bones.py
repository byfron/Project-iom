# IMPORTANT: make sure no animation is assigned
# to the rig before you run this script,
# otherwise linked animation data will be corrupted.

import bpy
import pdb

# ----------------------------------
# Mixamo left/right bone names start with 'Left'/'Right'
# Instead we apply Blender's standard .L/.R suffix
# and get rid of long suffix
# ----------------------------------

def makeStandardBoneName(x):
    if ':' in x:
        subx = x.split(':')
        return subx[1]
    return x

    x = x[10:]
    if 'Left' in x:
        x = x[4:]+".L"
    if 'Right' in x:
        x = x[5:]+".R"
    return x

# ----------------------------------
# Standardize bone names.
# ----------------------------------

for armature in bpy.data.armatures:
    for bone in armature.bones:
        print(bone.name)
        n = bone.name
        if 'mixamorig' in n:
            bone.name = makeStandardBoneName(n)

# ----------------------------------
# Convert animation channel names
# ----------------------------------

# for action in bpy.data.actions:
#    for curve in action.fcurves:
#        p = curve.data_path
#        if 'mixamorig' in p:
#            e = p.split("\"")
#            x = makeStandardBoneName(e[1])
#            curve.data_path = e[0]+"\""+x+"\""+e[2]

#active_scene = bpy.data.scenes.active
filename = bpy.data.filepath
#bpy.Save(filename,1)
bpy.ops.wm.save_as_mainfile(filepath=filename)
