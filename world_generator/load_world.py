from aseprite import *
import numpy as np
import pdb
import matplotlib.pyplot as plt
import graphics_db

class BlitFrame(object):
    """A blit frame just holds a frame's data and its dimension."""
    def __init__(self, width, height, default_color):
        self.width = width
        self.height = height
        self.data = [[default_color for col in range(width)] for row in range(height)]

    def basic_blit_cel_on_self(self, cel, mask_index):
        """Take a CelChubk and apply its data over the BlitFrame's. Assumes that the data is in indexed mode."""
        for x in range(cel.data['width']):
            for y in range(cel.data['height']):
                current_index = cel.data["data"][y * cel.data['width'] + x]
                if current_index != mask_index:
                    self.data[y + cel.y_pos][x + cel.x_pos] = current_index

    def basic_blit_on(self, target, mask_index):
        """Blits self's data over another BlitFrame"""
        for y, pixel_slice in enumerate(self.data):
            for x, pixel in enumerate(pixel_slice):
                if pixel != mask_index:
                    target.data[y][x] = pixel

def extract_layer(picture, layer_name):

    def indexed_blit_single_layer(picture, layer, cels, num_frame, frame_output):
        current_cel = cels[layer.layer_index]
        if current_cel:
            frame_output.basic_blit_cel_on_self(current_cel, picture.header.palette_mask)

    def indexed_blit_layer_group(picture, layer, cels, num_frame, frame_output):
        temporary_frame = BlitFrame(frame_output.width, frame_output.height, picture.header.palette_mask)
        for child in layer.children:
            if isinstance(child, LayerGroupChunk):
                indexed_blit_layer_group(picture, child, cels, num_frame, frame_output)
            else:
                indexed_blit_single_layer(picture, child, cels, num_frame, frame_output)

        temporary_frame.basic_blit_on(frame_output, picture.header.palette_mask)
    
    num_frame = 0
    cel_slice = [None] * len(picture.layers)
    for chunk in picture.frames[num_frame].chunks:
        if isinstance(chunk, CelChunk):
            cel_slice[chunk.layer_index] = chunk
    frame_output = BlitFrame(picture.header.width, picture.header.height, picture.header.palette_mask)

    layer_names = [x.name for x in picture.layers]
    if layer_name not in layer_names:
        print('Cannot find layer %s' % layer_name)
        return None

    layer = picture.layers[layer_names.index(layer_name)]
    if isinstance(layer, LayerGroupChunk):
        indexed_blit_layer_group(picture, layer, cel_slice, num_frame, frame_output)
    else:
        indexed_blit_single_layer(picture, layer, cel_slice, num_frame, frame_output)

    return frame_output

class WorldLevel:
    def __init__(self, level):
        self.level = level
        self.layers = {}

def load_world_from_aseprite(world_aseprite_file, level):

    print('Loading ' + world_aseprite_file + ' in level:' + str(level))
    
    with open(world_aseprite_file, 'rb') as f:
        parsed_file = AsepriteFile(f.read())

        
    ground_layer = extract_layer(parsed_file, 'Ground')
    overground_layer = extract_layer(parsed_file, 'OverGround')
    object_layer = extract_layer(parsed_file, 'Object')

    world = WorldLevel(level)
    world.layers = {graphics_db.GROUND_LAYER: np.array(ground_layer.data),
                    graphics_db.OVERGROUND_LAYER: np.array(overground_layer.data),
                    graphics_db.OBJECT_LAYER: np.array(object_layer.data)}

    return world
