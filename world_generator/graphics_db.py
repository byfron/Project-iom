#Indices acoording to the Aurora palette for each layer:
# Ground (water, forest, house floors, roads, etc...)
# Dwellings (walls, constructions, doors, grass, and whatever elements that shoud be on top of the floor but behind the player)
# Objects: Elements that could potentially be in front of the player (lamps, trees, etc...)
# Note that indices could be repeated across layers
import pdb
import numpy as np

#TODO: put this in a json! Layers
GROUND_LAYER = 1
OVERGROUND_LAYER = 2
OBJECT_LAYER = 3
META_LAYER = 4

#GROUND LAYER
WATER1 = 47
WATER2 = 48
SAND1 = 72
SAND2 = 73
SAND3 = 74
GRASS1 = 184
GRASS2 = 185
GRASS3 = 186
GRASS4 = 187
ROCK = 117
WOOD_FLOOR = 163
STONE_FLOOR = 11

#OVERLAY LAYER
WALL1 = 154
DOOR1 = 252
DOOR2 = 245
DOOR2SIDE = 244
DOOR1_OPEN = 254
DOOR1SIDE = 250
DOOR1SIDE_OPEN = 251

WINDOW1SIDE = 39
WINDOW1 = 40
PLANT1 = 41
PLANT2 = 42
PLANT3 = 43
PLANT4 = 44
PLANT5 = 45

#OBJECT LAYER
LAMP = 76
CAMP_FIRE=75
TREE1 = 92
BENCH = 60
BARREL = 66
BED = 63
FRIDGE = 131
STOVE = 134
TABLE = 64
MANHOLE = 65
LADDER = 67



def hmap_to_ground_lid(hv):
    lids = [WATER1, WATER2, SAND1, SAND2, SAND3, GRASS1, GRASS2, GRASS3, GRASS4, ROCK]
    lid = int(hv * (len(lids)-1))
    return lids[lid]

def get_color(lid):
    return Label.palette[lid,:]

class Label:
    palette = np.array([[  0,   0,   0],
                        [ 17,  17,  17],
                        [ 34,  34,  34],
                        [ 51,  51,  51],
                        [ 68,  68,  68],
                        [ 85,  85,  85],
                        [102, 102, 102],
                        [119, 119, 119],
                        [136, 136, 136],
                        [153, 153, 153],
                        [170, 170, 170],
                        [187, 187, 187],
                        [204, 204, 204],
                        [221, 221, 221],
                        [238, 238, 238],
                        [255, 255, 255],
                        [127, 127,   0],
                        [191, 191,  63],
                        [255, 255,   0],
                        [255, 255, 191],
                        [255, 129, 129],
                        [255,   0,   0],
                        [191,  63,  63],
                        [127,   0,   0],
                        [ 80,  15,  15],
                        [127,   0, 127],
                        [191,  63, 191],
                        [245,   0, 245],
                        [255, 129, 253],
                        [203, 192, 255],
                        [129, 129, 255],
                        [  0,   0, 255],
                        [ 63,  63, 191],
                        [  0,   0, 127],
                        [ 20,  20,  85],
                        [  0,  63, 127],
                        [ 63, 127, 191],
                        [  0, 127, 255],
                        [129, 191, 255],
                        [191, 255, 255],
                        [  0, 255, 255],
                        [ 63, 191, 191],
                        [  0, 127, 127],
                        [  0, 127,   0],
                        [ 63, 191,  63],
                        [  0, 255,   0],
                        [175, 255, 175],
                        [255, 191,   0],
                        [255, 127,   0],
                        [200, 125,  75],
                        [192, 175, 188],
                        [137, 170, 203],
                        [144, 160, 166],
                        [148, 148, 126],
                        [135, 130, 110],
                        [ 96, 110, 126],
                        [ 95, 105, 160],
                        [114, 120, 192],
                        [116, 138, 208],
                        [125, 155, 225],
                        [140, 170, 235],
                        [155, 185, 245],
                        [175, 200, 246],
                        [210, 225, 245],
                        [255,   0, 127],
                        [ 59,  59,  87],
                        [ 60,  65, 115],
                        [ 85,  85, 142],
                        [115, 115, 171],
                        [143, 143, 199],
                        [171, 171, 227],
                        [218, 210, 248],
                        [171, 199, 227],
                        [115, 158, 196],
                        [ 87, 115, 143],
                        [ 59,  87, 115],
                        [ 31,  45,  59],
                        [ 35,  65,  65],
                        [ 59, 115, 115],
                        [ 87, 143, 143],
                        [ 85, 162, 162],
                        [114, 181, 181],
                        [143, 199, 199],
                        [171, 218, 218],
                        [199, 237, 237],
                        [171, 227, 199],
                        [143, 199, 171],
                        [ 85, 190, 142],
                        [ 87, 143, 115],
                        [ 62, 125,  88],
                        [ 50,  80,  70],
                        [ 15,  30,  25],
                        [ 55,  80,  35],
                        [ 59,  87,  59],
                        [ 80, 100,  80],
                        [ 73, 115,  59],
                        [ 87, 143,  87],
                        [115, 171, 115],
                        [130, 192, 100],
                        [143, 199, 143],
                        [162, 216, 162],
                        [250, 248, 225],
                        [202, 238, 180],
                        [197, 227, 171],
                        [142, 180, 135],
                        [ 95, 125,  80],
                        [ 70, 105,  15],
                        [ 35,  45,  30],
                        [ 70,  65,  35],
                        [115, 115,  59],
                        [171, 171, 100],
                        [199, 199, 143],
                        [227, 227, 171],
                        [241, 241, 199],
                        [240, 210, 190],
                        [227, 199, 171],
                        [220, 185, 168],
                        [199, 171, 143],
                        [199, 143,  87],
                        [143, 115,  87],
                        [115,  87,  59],
                        [ 45,  25,  15],
                        [ 59,  31,  31],
                        [ 87,  59,  59],
                        [115,  73,  73],
                        [143,  87,  87],
                        [170, 110, 115],
                        [202, 118, 118],
                        [199, 143, 143],
                        [227, 171, 171],
                        [248, 218, 208],
                        [255, 227, 227],
                        [199, 143, 171],
                        [199,  87, 143],
                        [143,  87, 115],
                        [115,  59,  87],
                        [ 60,  35,  60],
                        [ 70,  50,  70],
                        [114,  64, 114],
                        [143,  87, 143],
                        [171,  87, 171],
                        [171, 115, 171],
                        [225, 172, 235],
                        [245, 220, 255],
                        [227, 199, 227],
                        [210, 185, 225],
                        [190, 160, 215],
                        [185, 143, 199],
                        [160, 125, 200],
                        [145,  90, 195],
                        [ 55,  40,  75],
                        [ 35,  22,  50],
                        [ 30,  10,  40],
                        [ 17,  24,  64],
                        [  0,  24,  98],
                        [ 10,  20, 165],
                        [ 16,  32, 218],
                        [ 74,  82, 213],
                        [ 10,  60, 255],
                        [ 50,  90, 245],
                        [ 98,  98, 255],
                        [ 49, 189, 246],
                        [ 60, 165, 255],
                        [ 15, 155, 215],
                        [ 10, 110, 218],
                        [  0,  90, 180],
                        [  5,  75, 160],
                        [ 20,  50,  95],
                        [ 10,  80,  83],
                        [  0,  98,  98],
                        [ 90, 128, 140],
                        [  0, 148, 172],
                        [ 10, 177, 177],
                        [ 90, 213, 230],
                        [ 16, 213, 255],
                        [ 74, 234, 255],
                        [ 65, 255, 200],
                        [ 70, 240, 155],
                        [ 25, 220, 150],
                        [  5, 200, 115],
                        [  5, 168, 106],
                        [ 20, 110,  60],
                        [  5,  52,  40],
                        [  8,  70,  32],
                        [ 12,  92,  12],
                        [  5, 150,  20],
                        [ 10, 215,  10],
                        [ 10, 230,  20],
                        [115, 255, 125],
                        [ 90, 240,  75],
                        [ 20, 197,   0],
                        [ 80, 180,   5],
                        [ 78, 140,  28],
                        [ 50,  56,  18],
                        [128, 152,  18],
                        [145, 196,   6],
                        [106, 222,   0],
                        [168, 235,  45],
                        [165, 254,  60],
                        [205, 255, 106],
                        [255, 235, 145],
                        [255, 230,  85],
                        [240, 215, 125],
                        [213, 222,   8],
                        [222, 156,  16],
                        [ 92,  90,   5],
                        [ 82,  44,  22],
                        [125,  55,  15],
                        [156,  74,   0],
                        [150, 100,  50],
                        [246,  82,   0],
                        [189, 106,  24],
                        [220, 120,  35],
                        [195, 157, 105],
                        [255, 164,  74],
                        [255, 176, 144],
                        [255, 197,  90],
                        [250, 185, 190],
                        [240, 110, 120],
                        [255,  90,  74],
                        [246,  65,  98],
                        [245,  60,  60],
                        [218,  28,  16],
                        [189,  16,   0],
                        [148,  16,  35],
                        [ 72,  33,  12],
                        [176,  16,  80],
                        [208,  16,  96],
                        [210,  50, 135],
                        [255,  65, 156],
                        [255,  98, 189],
                        [255, 145, 185],
                        [255, 165, 215],
                        [250, 195, 215],
                        [252, 198, 248],
                        [255, 115, 230],
                        [255,  82, 255],
                        [224,  32, 218],
                        [255,  41, 189],
                        [197,  16, 189],
                        [190,  20, 140],
                        [123,  24,  90],
                        [100,  20, 100],
                        [ 98,   0,  65],
                        [ 70,  10,  50],
                        [ 55,  25,  85],
                        [130,  25, 160],
                        [120,   0, 200],
                        [191,  80, 255],
                        [197, 106, 255],
                        [185, 160, 250],
                        [140,  58, 252],
                        [120,  30, 230],
                        [ 57,  16, 189],
                        [ 77,  52, 152],
                        [ 55,  20, 145]])
    
    def __init__(self, lid, name, layer):
        self.lid = lid
        self.name = name
        self.layer = layer        
        self.color = get_color(self.lid)
            


labels = [
    Label(WATER1, 'water1', GROUND_LAYER),
    Label(WATER2, 'water2', GROUND_LAYER),
    Label(SAND1, 'sand1', GROUND_LAYER),
    Label(SAND2, 'sand2', GROUND_LAYER),
    Label(SAND3, 'sand3', GROUND_LAYER),
    Label(GRASS1, 'grass1', GROUND_LAYER),
    Label(GRASS2, 'grass2', GROUND_LAYER),
    Label(GRASS3, 'grass3', GROUND_LAYER),
    Label(GRASS4, 'grass4', GROUND_LAYER),
    Label(ROCK, 'rock', GROUND_LAYER),
    Label(WOOD_FLOOR, 'wood_floor', GROUND_LAYER),
    Label(STONE_FLOOR, 'stone_floor', GROUND_LAYER),    
    Label(WALL1, 'wall1', OVERGROUND_LAYER),
    Label(DOOR1, 'door1', OVERGROUND_LAYER),
    Label(WINDOW1, 'window1', OVERGROUND_LAYER)
    ]

    
    


#FLOOR LAYER





#DWELLINGS LAYER





#OBJECT LAYER







# #TILES
# GRASS_TILE = 5
# WALL_TILE = 1
# FLOOR_TILE = 2
# CLOSED_DOOR_TILE = 3
# OPEN_DOOR_TILE = 4
# WINDOW_TILE = 5

# ROAD_TILE = 7
# POND_TILE = 8
# TREE_TILE_1 = 9
# FENCE_TILE = 10

# WATER1 = 50
# WATER2 = 51
# SAND1 = 52
# SAND2 = 53
# SAND3 = 54
# GRASS1 = 55
# GRASS2 = 56
# GRASS3 = 57
# GRASS4 = 58
# ROCK = 59


# #OBJECTS
# STAIRS_DOWN = 100
# STAIRS_UP = 101
# TABLE = 102
# FRIDGE = 103
# LAMP = 104
# STOVE = 105
# BED = 106
# CLOSET = 107

# PLANT_TILE_1 = 200
# PLANT_TILE_2 = 201
# PLANT_TILE_3 = 202
# PLANT_TILE_4 = 203
# PLANT_TILE_5 = 204
# PLANT_TILE_6 = 205
