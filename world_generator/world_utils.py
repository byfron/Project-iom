import pdb
from entity_creators import *
import graphics_db
import numpy as np

def create_doors(world):

    #TODO: FIX THIS!!
    
    front_door_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.DOOR1))
    front_door_locations = front_door_locations.transpose().tolist()
#    door_type_id = 252
    for loc in front_door_locations:
        create_door(252, [loc[0], loc[1], world.level], False)

    front_door_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.DOOR2))
    front_door_locations = front_door_locations.transpose().tolist()
    for loc in front_door_locations:
        create_door(245, [loc[0], loc[1], world.level], False)        

    front_door_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.DOOR2SIDE))
    front_door_locations = front_door_locations.transpose().tolist()
    for loc in front_door_locations:
        create_door(244, [loc[0], loc[1], world.level], False)        
        
    #TODO: use template for doors!
    side_door_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.DOOR1SIDE))
    side_door_locations = side_door_locations.transpose().tolist()
#    door_type_id = 252
    for loc in side_door_locations:
        create_door(250, [loc[0], loc[1], world.level], False)
                
def create_windows(world):
    window_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.WINDOW1))
    window_locations = window_locations.transpose().tolist()
    for loc in window_locations:
        create_window([loc[1], loc[0], world.level], False)
        world.layers[graphics_db.META_LAYER][loc[0], loc[1]] = 2

        
def create_objects(world):
    object_locations = np.vstack(np.where(world.layers[graphics_db.OBJECT_LAYER] > 0)).transpose().tolist()

    #TODO: Take into account elements that take two tiles so that we don't create two entities    
    for loc in object_locations:
        location = [loc[0], loc[1], world.level]
        object_id = world.layers[graphics_db.OBJECT_LAYER][loc[0], loc[1]]
        create_object(object_id, location)

def create_characters(world):
#   location = [462, 344, 0]
    location = [460, 363, 1]
#    location = [459, 354, 0]
    character_id = 10

    #TODO: create character and create_player coords are inverted!!!
#    create_character(10, location)

    create_character(40, location)


    #TODO: this locations seem to not match exactly with the tiles in
    #aseprite. There has to be a bug somewhere.
    #create_character(character_id, [460, 338, 0])

    #Create 3 rats in the basement
    #create_character(11, [446, 351, 1])
    #create_character(11, [450, 351, 1])
    #create_character(11, [447, 352, 1])

    #TODO: add rat meat in their inventory


def create_lights(world):
    #create lights at the top of lamp posts
    lamp_locations = np.vstack(np.where(world.layers[graphics_db.OBJECT_LAYER] == graphics_db.LAMP)).transpose()
    for loc in lamp_locations:
        if world.layers[graphics_db.OBJECT_LAYER][loc[0]+1, loc[1]] == graphics_db.LAMP:
            create_light([loc[1], loc[0], world.level])

    
    #fire locations
    fire_locations = np.vstack(np.where(world.layers[graphics_db.OBJECT_LAYER] == graphics_db.CAMP_FIRE)).transpose()
    for loc in fire_locations:
        create_fire([loc[1], loc[0], world.level])
