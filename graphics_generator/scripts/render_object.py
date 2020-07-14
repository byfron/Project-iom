import bpy
import pdb
import sys
import os

def get_object_centroid_empty(collection):    
    return collection.all_objects[0]

scene = bpy.context.scene
subfolder = 'objects'
if not os.path.exists(subfolder):
        os.mkdir(subfolder)

camera_collections = bpy.data.collections['Cameras']

for camera in camera_collections.all_objects:
    object_name = camera.name
    opath = subfolder + '/' + object_name
    if not os.path.exists(opath):
        os.mkdir(opath)

    camera = scene.objects[camera.name]
    bpy.context.scene.camera = camera
    diffuse_out_node = scene.node_tree.nodes['DiffuseOutput']
    normal_out_node = scene.node_tree.nodes['NormalOutput']
    diffuse_out_node.file_slots[0].path = 'DIFFUSE'
    normal_out_node.file_slots[0].path = 'NORMAL'
    diffuse_out_node.base_path = opath
    normal_out_node.base_path = opath

    bpy.ops.render.render(write_still = True)
