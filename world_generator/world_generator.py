from generator import Generator
from load_world import load_world_from_aseprite
import json
import pdb
import graphics_db
from world_utils import *
from entity_creators import create_player
from ecs_utils import EntityFactory, ActionFactory

class WorldGenerator(Generator):
    def __init__(self,settings):
        self.settings = settings
        super().__init__()

    def generate_meta_layer(self, world):        #TODO: work this out

        #encoding:
        #8 bits:
        #0 bit: fov
        #1 bit: obstacle
        #2-8: heightbent
        
        
        #mask = (
        #    (world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.WALL1) +
        #    (world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.WALL2) +
        #    (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.WINDOW1) +
        #    (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.WINDOW1SIDE) +            
        #    (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.DOOR1))

        #make tree obstacles
        mask = (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.TREE1)
        mask += (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.TREE2)
        mask += (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.TREE3)
        mask += (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.TREE4)
        mask += (world.layers[graphics_db.OBJECT_LAYER] == graphics_db.TREE5)

        mask2 = world.layers[graphics_db.GROUND_LAYER] == graphics_db.WATER2
        
        height_mask_2 = (
            (world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.WALL1) +
            (world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.WALL2))

        height_mask_1 = world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.RUINS

        height_meta = (height_mask_2 > 0).astype('uint8') * 14 #1110 (height = 3m)
        height_meta += (height_mask_1 > 0).astype('uint8') * 6 #0110 (height = 1m)
        
        return height_meta + (mask > 0).astype('uint8')*3 + (mask2 > 0).astype('uint8')*2

    def create_entities(self, world):
        #maybe refactor doors and windows as objects too?
#        create_doors(world)
        create_windows(world)               
        create_objects(world)
        create_lights(world)
        create_locks_and_keys(world)
    
    def generate(self):
        levels = self.settings['world']                      
        for level in levels: 
            world = load_world_from_aseprite(level['map_file'], level['level'])
            world.layers[graphics_db.META_LAYER] = self.generate_meta_layer(world)
            self.create_entities(world)
            self.create_chunk_entities(world)
            
        ActionFactory.create_actions()
        return world, self.entities

class WorldSettingsLoader:
    level = 0
    def __init__(self, settings_file):
        self.config_json_file = settings_file
        with open(settings_file, 'r') as fp:
            self.settings = json.load(fp)
            
if __name__ == "__main__":
    settings_file = 'world.json'
    sloader = WorldSettingsLoader(settings_file)
    world, entities = WorldGenerator(sloader.settings).generate()    

    #Upstairs (first)
    coord = [339, 457, 0]
    #Downstarirs
    coord = [358, 465, 1]

    coord = [21, 92, 0]

    coord = [58, 43, 0]
    coord = [63, 85, 0]
    coord = [7, 30, 0]
    coord = [42, 22, 0]    #north ruins
    coord = [67, 24, 1]    #underground door
    coord = [36, 74, 0]    #south ruins
    coord = [56, 8, 1]    #underground chest

    coord = [7, 31, 0]    #top initial pos
    
#    coord = [31, 84, 1]
#    coord = [73, 17, 1]
#    coord = [92, 26, 0]

    
    #New kitchen window blowout
    #coord = [354, 457, 0]

    #coord = [47, 87, 0]
    
    create_player(coord)
    create_characters(world)
    
    EntityFactory.dump_entity_pool('world.bin')

