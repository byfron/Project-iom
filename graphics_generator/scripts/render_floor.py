import bpy
import pdb
import sys
import os

scene = bpy.context.scene

floor_dir = 'floors_materials'

if not os.path.exists(floor_dir):
    os.mkdir(floor_dir)

materials = ['StoneSand', 'StoneGrass', 'SandGrass', 'SandWater', 'GrassGrass2']
floor_object = scene.objects['FloorPlane']

for material_name in materials:

    mat = bpy.data.materials[material_name]
    camera = scene.objects['Camera']
    diffuse_render_file = floor_dir + '/DIF_' + material_name + '.jpg'
    normal_render_file = floor_dir + '/NRM_' + material_name + '.jpg'
    floor_object.data.materials[0] = mat
    
    bpy.context.scene.camera = camera
    material_nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    diffuse_node = material_nodes['DiffuseShader']
    normal_node = material_nodes['NormalShader']


    output_node = material_nodes['Output']
    
    #Connect output to diffuse
    l = links.new(diffuse_node.outputs[0], output_node.inputs[0])
    file_out_node = scene.node_tree.nodes['FileOutput']
    file_out_node.file_slots[0].path = 'DIFFUSE_'
    file_out_node.base_path = material_name
    bpy.ops.render.render(write_still = True)

    links.remove(l)
    
    #Connect output to normal
    links.new(normal_node.outputs[0], output_node.inputs[0])
    file_out_node = scene.node_tree.nodes['FileOutput']
    file_out_node.file_slots[0].path = 'NORMAL_'
    file_out_node.base_path = material_name
    bpy.ops.render.render(write_still = True)

    



