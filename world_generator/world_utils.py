import pdb
from entity_creators import *
import graphics_db
import numpy as np

def create_doors(world):

    #TODO: FIX THIS!!
    
    front_door_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.DOOR1))
    front_door_locations = front_door_locations.transpose().tolist()
    for loc in front_door_locations:
        create_door(graphics_db.DOOR1, [loc[0], loc[1], world.level], False)
                
def create_windows(world):
    window_locations = np.vstack(np.where(world.layers[graphics_db.OVERGROUND_LAYER] == graphics_db.WINDOW1))
    window_locations = window_locations.transpose().tolist()
    for loc in window_locations:
        create_window([loc[1], loc[0], world.level], False)
        world.layers[graphics_db.META_LAYER][loc[0], loc[1]] = 2

def object_has_volume(object_id):
    pass

def look_for_neighbour_walls(wmap, loc):
    if wmap[loc[0], loc[1]-1] > 0:
        return 'N'
    else:
        return 'W'

def look_for_neighbour_object(omap, loc):
    if omap[loc[0], loc[1]-1] > 0:
        return 'W'
    if omap[loc[0], loc[1]+1] > 0:
        return 'E'
    if omap[loc[0]-1, loc[1]] > 0:
        return 'N'
    if omap[loc[0]+1, loc[1]] > 0:
        return 'S'
    return None

def create_objects(world):
    object_locations = np.vstack(np.where(world.layers[graphics_db.OBJECT_LAYER] > 0)).transpose().tolist()

    volume_list = []
    
    #TODO: Take into account elements that take two tiles so that we don't create two entities    
    for loc in object_locations:
        location = [loc[0], loc[1], world.level]
        object_id = world.layers[graphics_db.OBJECT_LAYER][loc[0], loc[1]]

        #If it has orientation... check around for any other object and orient it towards it
        direction = None
        if ObjectTemplate.object_has_component(object_id, 'orientation'):
            if ObjectTemplate.object_has_component(object_id, 'door'):
                direction = look_for_neighbour_walls(world.layers[graphics_db.OVERGROUND_LAYER], location)
            else:
                direction = look_for_neighbour_object(world.layers[graphics_db.OBJECT_LAYER], location)
                
        #how to handle areas/volumes? We should create only ONE object
        #if it defines a volume in the map. Keep a list of "locations" to fill.
        #Create the object once all the locations are filled. Otherwise throw an error
        #put location and id in a list?
        
        #if has volume, add to list of "id, position, volume"
        if ObjectTemplate.object_has_component(object_id, 'volume'):
            volume_comp = ObjectTemplate.object_get_volume(object_id)
            volume_list.append((object_id, location, volume_comp))
            if volume_comp[0] == 1 and volume_comp[1] == 1:
                create_object(object_id, location, direction)
        else:
            create_object(object_id, location, direction)


    #Create a mask to record used tiles
    tile_mask = world.layers[graphics_db.OBJECT_LAYER] > 0
            
    #For all voumes in the list
    for triplet in volume_list:

        volume = triplet[2]
        loc = triplet[1]
        object_id = triplet[0]
        
        #If has not been visited yet,
        if tile_mask[loc[0], loc[1]]:
            
            size_x = volume[0]
            size_y = volume[1]

            top_left, blob_size = find_volume_in_layer(world.layers[graphics_db.OBJECT_LAYER], object_id, size_x, size_y, loc)

            location = [top_left[0], top_left[1], world.level]
            create_object(object_id, location)

            #unmark all tiles for this volume
            tile_mask[top_left[0]:top_left[0]+blob_size[0], top_left[1]:top_left[1]+blob_size[1]] = 0
    

    
def find_volume_in_layer(object_map, object_id, size_x, size_y, loc):

    #look for N neighbors up/down and left right. Stop when no neighbor found and report (minimum) size of quad
    n_neighbors = 4
    x_size_pos = 0
    x_size_neg = 0    
    y_size_pos = 0
    y_size_neg = 0    

    for nx in range(1, n_neighbors):
        if object_map[loc[0] + nx][loc[1]] == object_id:
            y_size_pos += 1
        if object_map[loc[0] - nx][loc[1]] == object_id:
            y_size_neg += 1                                   

    for ny in range(1, n_neighbors):
        if object_map[loc[0]][loc[1] + ny] == object_id:
            x_size_pos += 1                                   
        if object_map[loc[0]][loc[1] - ny] == object_id:
            x_size_neg += 1                                   

    top_left = [loc[0] + y_size_neg, loc[1] + x_size_neg]
    size = [y_size_pos - y_size_neg + 1, x_size_pos - x_size_neg + 1]
    return top_left, size

def create_characters(world):
#   location = [462, 344, 0]
    location = [45, 55, 0]
#    location = [459, 354, 0]
    character_id = 40

    #TODO: create character and create_player coords are inverted!!!
#    create_character(10, location)

#    create_character(41, location)

    create_character(41, [80, 62, 0])

    #Create Eric
    create_character(10, [55, 55, 0])

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
