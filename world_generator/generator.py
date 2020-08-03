import pdb
import cv2
import numpy as np
import matplotlib.pyplot as plt
import sys
sys.path.append('../src/')
from map_utils import get_chunk_coords_from_offset_coords, get_bb_from_chunk_coords, MapSettings, MapBoundingBox
import graphics_db
from shapely import geometry
from ecs_utils import *

def compute_intersection(bb1, bb2):
    return MapBoundingBox.intersection(bb1, bb2)

    #return [max(bb1[0], bb2[0]), max(bb1[1], bb2[1]), min(bb1[2], bb2[2]), min(bb2[3], bb1[3])]

def crop_map(tilemap, bb, chunk_bb):

    if not MapBoundingBox.intersect(bb, chunk_bb):
        return tilemap

    ibb = compute_intersection(bb, chunk_bb)
    if ibb == bb:
       return tilemap

    srow = ibb.get_tl()[1] - chunk_bb.get_tl()[1]
    scol = ibb.get_tl()[0] - chunk_bb.get_tl()[0]
    erow = ibb.get_br()[1] - chunk_bb.get_tl()[1]
    ecol = ibb.get_br()[0] - chunk_bb.get_tl()[0]

    return tilemap[srow:erow, scol:ecol]

def get_cropped_tilemap(bb, tilemap_bb, tilemap):
    #crop BB(chunk) out of tilemap_bb

    start_offset_c = max(0, tilemap_bb.get_tl()[0] - bb.get_tl()[0])
    start_offset_r = max(0, tilemap_bb.get_tl()[1] - bb.get_tl()[1])

    chunk_tilemap = np.zeros((MapSettings.height, MapSettings.width), dtype=np.uint8)

    #crop tilemap
    cropped_tilemap = crop_map(tilemap, tilemap_bb, bb)

    # print(bb)
    # print(tilemap_bb)
    # print(cropped_tilemap)


    start_offset_c2 = max(0, bb.get_tl()[0] - tilemap_bb.get_tl()[0])
    start_offset_r2 = max(0, bb.get_tl()[1] - tilemap_bb.get_tl()[1])
    end_offset_c2 = min(tilemap.shape[1], bb.get_br()[0] - tilemap_bb.get_tl()[0]+1)
    end_offset_r2 = min(tilemap.shape[0], bb.get_br()[1] - tilemap_bb.get_tl()[1]+1)

    end_offset_c = min(MapSettings.width, start_offset_c + end_offset_c2 - start_offset_c2)
    end_offset_r = min(MapSettings.height, start_offset_r + end_offset_r2 - start_offset_r2)
    cropped_tilemap = tilemap[start_offset_r2:end_offset_r2, start_offset_c2:end_offset_c2]

    
    if end_offset_r > start_offset_r and end_offset_c > start_offset_c:
        try:
            chunk_tilemap[start_offset_r:end_offset_r , start_offset_c:end_offset_c] = cropped_tilemap
        except:
            pdb.set_trace()
        
    return chunk_tilemap

class Tilemap:
    def __init__(self, bb, level, tilemap):
        self.level = level
        self.tl = bb.get_tl()
        self.br = bb.get_br()
        self.data = tilemap
#        self.bbox = geometry.Polygon([self.tl, [self.tl[0], self.br[1]], [self.br[0], self.tl[1]], self.br])


def get_cropped_labelmap(label_map, tl, br):
    return label_map[tl[1]:br[1], tl[0]:br[0]]

class Generator:

    def __init__(self):
        self.entities = []
        
        pass

    def create_chunk_entities(self, world, tl=None, br=None):

        if tl == None or br == None:
            tl = [0, 0]
            br = [world.layers[graphics_db.GROUND_LAYER].shape[1],
                  world.layers[graphics_db.GROUND_LAYER].shape[0]]
        
        chunks = {}
        for layer_type in world.layers:
            layer_map = world.layers[layer_type]

            tilemap = get_cropped_labelmap(layer_map, tl, br)
            chunk_tilemaps = self.compute_chunks(MapBoundingBox.from_trbr(tl, br), tilemap)
            for key in chunk_tilemaps.keys():
                if key not in chunks:
                    chunks[key] = {graphics_db.GROUND_LAYER:[],
                                   graphics_db.OVERGROUND_LAYER: [],
                                   graphics_db.DECORATION_LAYER: [],
                                   graphics_db.OBJECT_LAYER:[],
                                   graphics_db.META_LAYER:[]}
                    chunks[key][layer_type].append(chunk_tilemaps[key])
                else:
                    chunks[key][layer_type].append(chunk_tilemaps[key])

        for chunk_c in chunks:
            chunk_layers = chunks[chunk_c]
            chunk_name = 'WorkdChunk_' + str(chunk_c)
            ent = EntityFactory.create_entity(chunk_name)
            pb_tilemaps = []
            for layer_type in chunk_layers:
                tilemaps = chunk_layers[layer_type]                
                for tilemap in tilemaps:

                    sx = tilemap.data.shape[0]
                    sy = tilemap.data.shape[1]
                    ttl = [chunk_c[0] * MapSettings.width, chunk_c[1] * MapSettings.height]
                    tbr = [(chunk_c[0] + 1) * MapSettings.width, (chunk_c[1] + 1) * MapSettings.height]
                    pb_tilemaps.append(MapUtils.create_tilemap('test_tilemap',  layer_type, ttl, tbr, world.level, tilemap.data.tobytes()))
                
            comp = ComponentFactory.create_chunk(chunk_c[0], chunk_c[1], world.level, pb_tilemaps)
            EntityFactory.attach_components(ent, [comp])                
            self.entities.append(ent)
            
        print('Generated % d chunks' % len(self.entities))  

    def compute_chunks(self, tilemap_bb, tilemap):

        chunk_tilemaps = {}
        tl = tilemap_bb.get_tl()
        br = tilemap_bb.get_br()

        #Check if the chunks we need are created already
        tl_chunk = get_chunk_coords_from_offset_coords(tl[0], tl[1])
        br_chunk = get_chunk_coords_from_offset_coords(br[0], br[1])
        tr_chunk = get_chunk_coords_from_offset_coords(br[0], tl[1])
        bl_chunk = get_chunk_coords_from_offset_coords(tl[0], br[1])

        chunk_list = [tl_chunk, br_chunk, tr_chunk, bl_chunk]
        min_chunk_coord = np.min(np.array(chunk_list), axis=0)
        max_chunk_coord = np.max(np.array(chunk_list), axis=0)


        for i in range(min_chunk_coord[0], max_chunk_coord[0]+1):
            for j in range(min_chunk_coord[1], max_chunk_coord[1]+1):
                chunk = (i, j)
                chunk_bb = get_bb_from_chunk_coords(chunk[0], chunk[1])

                #crop tilemap acoording to chunk
                chunk_tilemap = get_cropped_tilemap(chunk_bb, tilemap_bb, tilemap)

                if np.sum(chunk_tilemap) == 0:
                    continue

                if chunk in chunk_tilemaps:
                    self.combine_tilemaps(chunk_tilemaps[chunk], chunk_tilemap)
                else:
                    print('Creating chunk: %d, %d' % (chunk[0], chunk[1]))
                    chunk_tilemaps[chunk] = self.create_chunk_tilemap(chunk, chunk_tilemap)

        return chunk_tilemaps

    def combine_tilemaps(self, chunk_tmap, tmap):
        chunk_tmap.data[tmap != 0] = tmap[tmap != 0]

    def create_chunk_tilemap(self, chunk_coords, chunk_tilemap):
       bb = get_bb_from_chunk_coords(chunk_coords[0], chunk_coords[1])
       return Tilemap(bb, 0, chunk_tilemap)

wall_color = [0,0,0]
room_color = [0,0,255]
corner_color = [0,255,0]
cave_color = [255,255,255]
room_size_threshold = 20

wall_code = 1
room_code = 2

def get_mask(dmap, color):
    return ((dmap[:,:,0] == color[0]) * (dmap[:,:,1] == color[1]) * (dmap[:,:,2] == color[2])).astype('uint8')

# class DungeonRoom:
#     def __init__(self, x, y, patch):
#         self.x = x
#         self.y = y
#         self.patch = patch
#         self.size = patch.shape[0] * patch.shape[1]

# def get_rooms_by_size(room_labels):
#     rooms = []
#     sizes = []
#     for l in range(1, np.max(room_labels)):
#         patch = (room_labels == l).astype('int')
#         rows = np.where(patch)[0]
#         cols = np.where(patch)[1]
#         room_patch = patch[min(rows):max(rows), min(cols):max(cols)].astype('uint8')
#         size = np.sum(room_patch)
#         if size > room_size_threshold:
#             droom = DungeonRoom(min(rows), min(cols), room_patch)
#             sizes.append(size)
#             rooms.append(droom)

#     sorted_indices = [x for _,x in sorted(zip(sizes, list(range(0,len(rooms)))))]
#     sorted_rooms = [rooms[x] for x in sorted_indices]
#     return sorted_rooms

class DungeonGenerator:
    def __init__(self):
        pass

    def generate(self):

        qud_map = cv2.imread('Qud0.png')
        room_mask = get_mask(qud_map, room_color)
        wall_mask = get_mask(qud_map, wall_color)

        w = qud_map.shape[1]
        h = qud_map.shape[0]

        ddata = np.zeros((h,w))
        ddata = room_mask * room_code + wall_mask * wall_code

        center = (int(w/2), int(h/2))
        size = (w,h)
        color = 1
        circle_mask = np.zeros((h,w))
        cv2.circle(circle_mask, center, int(min(w,h)/2), color, -1)
        masked_dungeon = ddata# * circle_mask

        return masked_dungeon.astype(np.uint8)
