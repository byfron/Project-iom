import sys
sys.path.append('..')
from generator import Generator
from graphics_db import labels
import numpy as np
from voronoi import Voronoi, Polygon
import random
import noise
import cv2
from graphics_db import hmap_to_ground_lid
import pdb
import matplotlib.pyplot as plt

class WorldObject:
    def __init__(self):
        pass

def create_island_heightmap(polygon):

    allp = np.array([[p.x, p.y] for p in polygon.points])
    shape = np.max(allp, axis=0).tolist()
    scale = 4.0
    octaves = 11
    persistence = 0.5
    lacunarity = 2.0
    world = np.zeros(shape)
    freq = 16.0 * octaves
    rnd_z = random.random()
    for i in range(shape[0]):
        for j in range(shape[1]):
            world[i][j] = noise.snoise3(i / freq, j / freq, rnd_z, octaves)


    #create square gradient and mask image
    mask = np.ones(shape)
    for i in range(shape[0]):
        for j in range(shape[1]):
            x = i - shape[0]/2
            y = j - shape[1]/2
            d = max(abs(x), abs(y))
            mask[i,j] = max(0, d - 150)

    nmask = mask/np.max(mask)

    # plt.imshow(mask, cmap='gray')
    # plt.show()

    nworld = world - np.min(world)
    nworld /= np.max(nworld)
    nworld = np.maximum(np.zeros(shape), nworld - nmask)
    return nworld
    # plt.imshow(nworld, cmap='gray')
    # plt.show()

    
def run_Lloyd_relaxation(polygon, points):
     # Initialize the algorithm
    v = Voronoi(polygon)

    # Create the diagram
    v.create_diagram(points=points, vis_steps=False, verbose=False, vis_result=False, vis_tree=False)

    #run another iteration
    new_points = []
    for po in v.points:
        corners = []
        for e in v.edges:
            if e.incident_point == po:
                corners.append([e.origin.point.x, e.origin.point.y])

        if len(corners) > 2:
            new_points.append(np.mean(np.array(corners), axis=0).tolist())

    return np.array(new_points)


def generate_hmap(size):

    #Generate a bunch of random points
    points = size * np.random.random_sample((500, 2))
    num_iterations = 1

    # Define a bounding box
    polygon = Polygon([
        (0, 0),
        (0, size),
        (size, size),
        (size, 0)
    ])

    for i in range(num_iterations):
        points = run_Lloyd_relaxation(polygon, points)

    v = Voronoi(polygon)
    v.create_diagram(points=points, vis_steps=False, verbose=False, vis_result=False, vis_tree=False)

    #run perlin noise to figure out water/land polygons
    hmap = create_island_heightmap(polygon)

    return hmap


class Island(WorldObject):
    def __init__(self, hmap):
        self.hmap = hmap
        self.size = hmap.shape[0]
        self.label_map = self.get_label_map()
        self.object_map = np.zeros([self.hmap.shape[0]*4, self.hmap.shape[1]*4])
        self.overlay_map = np.zeros([self.hmap.shape[0]*4, self.hmap.shape[1]*4])
        self.meta_map = np.zeros([self.hmap.shape[0]*4, self.hmap.shape[1]*4])

    def get_abitable_surface(self):
        return self.label_map > graphics_db.WATER2

    def get_meta_map(self):
        return self.meta_map

    def get_object_map(self):
        return self.object_map

    def get_overlay_map(self):
        return self.overlay_map
        
    def get_floor_map(self):
        label_map = np.zeros([self.hmap.shape[0], self.hmap.shape[1]])
        for i in range(self.hmap.shape[0]):
            for j in range(self.hmap.shape[1]):
                h = self.hmap[i, j]
                lid = hmap_to_ground_lid(h)
                for label in labels:
                    if label.lid == lid:
                        label_map[i,j] = label.lid

        return cv2.resize(label_map, (self.size, self.size), cv2.INTER_NEAREST)
        
    def get_label_map(self):
        label_map = np.zeros([self.hmap.shape[0], self.hmap.shape[1]])
        for i in range(self.hmap.shape[0]):
            for j in range(self.hmap.shape[1]):
                h = self.hmap[i, j]
                lid = hmap_to_ground_lid(h)            
                for label in labels:
                    if label.lid == lid:
                        label_map[i,j] = label.lid

        return cv2.resize(label_map, (self.size, self.size), cv2.INTER_NEAREST)

    def get_colored_map(self):
        color_hm = np.zeros([self.hmap.shape[0], self.hmap.shape[1], 3])
        for i in range(self.hmap.shape[0]):
            for j in range(self.hmap.shape[1]):
                h = self.hmap[i, j]
                lid = hmap_to_ground_lid(h)
                for label in labels:

                    if label.lid == lid:
                        color_hm[i,j,:] = label.color

        colored_hmap =  color_hm/255.0
        return cv2.resize(colored_hmap, (self.size, self.size), cv2.INTER_NEAREST)

def combine_maps(wmap, cmap, rect):
    for i in range(cmap.shape[0]):
        for j in range(cmap.shape[1]):
            value = cmap[i,j]
            if value > 0:
                wmap[rect[0] + i, rect[1] + j] = value

    return wmap

# def create_vegetation(tl, br, meta_map, object_map, overlay_map):

#     mask = np.logical_and(np.logical_and(object_map, meta_map), overlay_map).astype('uint8')
    
#     #Generate trees randomly distributed uniformly
#     num_trees = 100
#     added_trees = 0
#     while added_trees < num_trees:
#         rnd_x = random.randrange(tl[0], br[0])
#         rnd_y = random.randrange(tl[1], br[1])

#         #check that we can add the tree here
#         if mask[rnd_y, rnd_x] == 0:
#             create_tree(rnd_x, rnd_y)
#             overlay_map[rnd_y, rnd_x] = graphics_db.TREE_TILE_1
#             overlay_map[rnd_y-1, rnd_x] = graphics_db.TREE_TILE_1
#             meta_map[rnd_y, rnd_x] = 1
#             added_trees += 1


#     #randomly add weeds
#     size_x = br[0] - tl[0]
#     size_y = br[1] - tl[1]
#     rnd_tilemap = np.random.randint(200, 205, size=[size_x, size_y], dtype=np.uint8)    
#     active_map = np.random.randint(25, size=[size_x, size_y], dtype=np.uint8)
#     rnd_tilemap[active_map > 5] = 0
#     pdb.set_trace()

def generator_to_image(gen):
    color_map = gen.get_label_map()
    filename = 'world.bmp'
#    im_rgb = cv2.cvtColor((color_map*255).astype('uint8'), cv2.COLOR_BGR2RGB)
    cv2.imwrite(filename, color_map)

class IslandGenerator(Generator):
    def __init__(self, settings):
        self.settings = settings
        super().__init__()        
        self.entities = []
        
    def generate(self):
        size = 1000
        island_map = generate_hmap(size)
        island = Island(island_map)
        # island_floor_map = island.get_floor_map()
        # island_object_map = island.get_object_map()
        # island_overlay_map = island.get_overlay_map()
        # island_meta_map = island.get_meta_map()

#        create_vegetation(tl, br, world_meta_map, world_object_map, world_overlay_map)

        world_map = {}
        world_map[graphics_db.GROUND_LAYER] = island.get_floor_map()
        world_map[graphics_db.OVERGROUND_LAYER] = island.get_object_map()
        world_map[graphics_db.OBJECT_LAYER] = island.get_overlay_map()
        world_map[graphics_db.META_LAYER] = island.get_meta_map()

        self.create_chunk_entities(world_map)
        return island, self.entities


class WorldSettings:
    def __init__(self):
        self.config_json_file = 'island.json'

            
if __name__ == "__main__":

    settings = WorldSettings()
    island, entities = IslandGenerator(settings).generate()
    generator_to_image(island)
    

