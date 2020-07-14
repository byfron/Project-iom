import bpy
import pdb
import sys
import os
import glob
import numpy as np

scene = bpy.context.scene
cameras = ['B_0', 'BL_1', 'LR_1', 'TB_1', 'TBG_1', 'TL_1', 'LR_1', 'TR_1', 'TBR_1', 'CROSS', 'LRT_1', 'LRB_1', 'BR_1']
object_name = 'Walls'
types = ['NORMAL', 'DIFFUSE']

for camera_name in cameras:
    camera = scene.objects[camera_name]
    if not os.path.exists(object_name):
        os.mkdir(object_name)

    diffuse_render_file = object_name + '/DIF_Camera_' + camera_name + '.jpg'
    normal_render_file = object_name + '/NRM_Camera_' + camera_name + '.jpg'
    bpy.context.scene.camera = camera

    diffuse_out_node = scene.node_tree.nodes['DiffuseOutput']
    normal_out_node = scene.node_tree.nodes['NormalOutput']

    diffuse_out_node.file_slots[0].path = 'DIFFUSE_Camera_' + camera_name
    normal_out_node.file_slots[0].path = 'NORMAL_Camera_' + camera_name
    
    diffuse_out_node.base_path = object_name
    normal_out_node.base_path = object_name

    bpy.ops.render.render(write_still = True)
