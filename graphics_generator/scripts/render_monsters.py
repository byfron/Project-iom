import bpy
import pdb
import sys
import os

scene = bpy.context.scene

animations = {'OrcWalk': [6, 14, 22, 31],
              'Melee': [10, 28, 57],
              'Death': [24, 45, 103],
              'HeadHit': [9],
              'JumpAttack': [11, 33, 54]}

cam_keys = ['N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE']

#v7_rigs = ['Joe']
#v1_rigs = ['Kate']
v0_rigs = ['Orc']
all_characters = {}
#all_characters['1'] = v1_rigs
#all_characters['7'] = v7_rigs
all_characters['0'] = v0_rigs

hips_bone = {}
hips_bone['7'] = 'mixamorig7:Hips'
hips_bone['1'] = 'mixamorig:Hips'
hips_bone['0'] = 'Hips'

argv = ''
if '--' in sys.argv:
    argv = sys.argv
    argv = argv[argv.index("--") + 1:]
    
if argv:
    animations = {argv[0]: animations[argv[0]]}

#Move all armatures away from camera
for armature in bpy.data.objects:
    if armature.type != 'ARMATURE':
        continue
    armature.location.z = -10000

for rig_type in all_characters:
    chars = all_characters[rig_type]
    bone_hips_name = hips_bone[rig_type]
    for character_name in chars:
        armature = scene.objects[character_name]

        if not os.path.exists(character_name):
            os.mkdir(character_name)
        
        for anim_name in animations:

            full_anim_name = anim_name# + 'V' + rig_type
            frames = animations[anim_name]
            action = bpy.data.actions[full_anim_name]
            armature.animation_data.action = action

            if not os.path.exists(character_name + '/' + anim_name):
                os.mkdir(character_name + '/' + anim_name)
                            
            armature = scene.objects[character_name]
            armature.location.x = 0
            armature.location.y = 0
            armature.location.z = 0
            for cam_key in cam_keys:
                frame_img_idx = 0
                for frame_i in frames:                
                    scene.frame_set(frame_i)
                    camera_name = 'Camera_' + cam_key
                    camera = scene.objects[camera_name]
                    camera.constraints['Damped Track'].target = armature

                    camera.constraints['Damped Track'].subtarget = bone_hips_name

#                    render_name = character_name + '/' + anim_name + '/Camera_' + cam_key + '_' + str(frame_img_idx)
                    bpy.context.scene.camera = camera

                    color_out_node = scene.node_tree.nodes['ColorOutput']
                    normal_out_node = scene.node_tree.nodes['NormalOutput']
                    color_out_node.file_slots[0].path = 'DIFFUSE_Camera' + cam_key + '_' + str(frame_img_idx)
                    normal_out_node.file_slots[0].path = 'NORMAL_Camera' + cam_key + '_' + str(frame_img_idx)
                    
                    color_out_node.base_path = character_name + '/' + anim_name + '/'
                    normal_out_node.base_path = character_name + '/' + anim_name + '/'

                    bpy.ops.render.render(write_still = True)
        
                    frame_img_idx += 1


    #Move armature out of the camera view
    armature.location.z = -10000



    
# main_armature = scene.objects['Joe']

# center_location = main_armature.location

# cl_x = 2.2785
# cl_y = -1.0592
# cl_z = -1.0



# for armature in bpy.data.objects:

#     if armature.type != 'ARMATURE':
#         continue

#     char_name = armature.name
#     #swap location of armatures
#     #if prev_armature:
#     #    prev_armature.location.z = -10000#armature.location

#     armature.location.x = cl_x
#     armature.location.y = cl_y
#     armature.location.z = cl_z


#     print('Rendering ' + char_name + ' in pos:' + str(cl_z))
    
#     #prev_armature = armature

#     #make all cameras point to the current armature
#     for cam_key in cam_keys:
#         camera_name = 'Camera_' + cam_key
#         camera = scene.objects[camera_name]
#         camera.constraints['Damped Track'].target = armature

#     os.mkdir(char_name)
#     for anim_name in animations:

#         frames = animations[anim_name]
#         if anim_name not in bpy.data.actions:
#             continue
    
#         action = bpy.data.actions[anim_name]
#         armature.animation_data.action = action
    
#         total_frames = len(frames)

#         #Create folder for this animation       
#         os.mkdir(char_name + '/' + anim_name)

#         frame_img_idx = 0
#         for frame_i in frames:
#             scene.frame_set(frame_i)
#             for cam_key in cam_keys:
#                 camera_name = 'Camera_' + cam_key
#                 camera = scene.objects[camera_name]
#                 render_file = char_name + '/' + anim_name + '/Camera_' + cam_key + '_' + str(frame_img_idx) + '.jpg'
#                 bpy.context.scene.camera = camera
#                 bpy.context.scene.render.filepath = render_file
#                 bpy.ops.render.render(write_still = True)
            
#             frame_img_idx += 1

#     #Move armature out of the camera view
#     armature.location.z = -10000
