from ecs_utils import EntityFactory, ComponentFactory
from entity_templates import ObjectTemplate, CharacterTemplate, WeaponTemplate, FoodTemplate, ItemTemplate
import RandomEngine
import random
import pdb
import graphics_db

def create_player(location):
    ent = EntityFactory.create_entity('player')
    loc = ComponentFactory.create_location(location)
    char = ComponentFactory.create_main_character('Johnny', 'M', 1, 0)
    mov = ComponentFactory.create_movement(1.0)
    ini = ComponentFactory.create_initiative(5)
    gr = ComponentFactory.create_graphics(1, 1, 1, 1)
    
    cstatus = ComponentFactory.create_char_status(False, False, False, False)


    #Let's create a weapon item and add it to the inventory of the main character
    weapon1 = create_weapon(1)
    weapon2 = create_weapon(2)
    food = create_random_food_item()
    
    #Let's put also a bottle in the inventory
    bottle = create_item(10)

    inv = ComponentFactory.create_inventory_with_stuff(20, [bottle.entity_id, weapon2.entity_id, weapon1.entity_id, food.entity_id], weapon2.entity_id)
    
    
    desc = ComponentFactory.create_description('Main character desc')
    skills = ComponentFactory.create_skills(**{'Brawler': 30, 'Stealth': 24, 'Firearms': 90})
    stats = ComponentFactory.create_char_stats(100, 80, 90, 100)
    
    EntityFactory.attach_components(ent, [loc, inv, char, mov, ini, gr, desc, skills, stats, cstatus])
    
def create_door(door_id, location, open_closed):
    ObjectTemplate.create_entity_with_location(door_id, location)
#    gr = ComponentFactory.create_graphics(1, 1, graphics_db.DOOR_1, 1)
    
    return 
#    ObjectTemplate.create_door_with_location(object_id, location)
    

    loc = ComponentFactory.create_location(location)
    door = ComponentFactory.create_door(False, False)
    desc = ComponentFactory.create_description('Wooden door. Looks very sturdy')
    #ComponentFactory.create_
    EntityFactory.attach_components(ent, [loc, door, desc])

def create_window(location, open_closed):    
    ent = EntityFactory.create_entity('window')
    loc = ComponentFactory.create_location(location)
#    door = ComponentFactory.create_door(False, False)
    desc = ComponentFactory.create_description('Window descr.')
    EntityFactory.attach_components(ent, [loc, desc])

def create_random_food_item():
    food_id = random.randint(1,2)
    return FoodTemplate.create_entity(food_id)

def create_item(item_id):
    return ItemTemplate.create_entity(item_id)

def create_object(object_id, location):
    return ObjectTemplate.create_entity_with_location(object_id, location)

def create_character(character_id, location):
    return CharacterTemplate.create_entity_with_location(character_id, location)

def create_weapon(weapon_id):
    return WeaponTemplate.create_entity(weapon_id)

def create_fire(location):
    #TODO: use a template
    ent = EntityFactory.create_entity('fire')
    loc = ComponentFactory.create_location(location)
    fire = ComponentFactory.create_fire(4)
    EntityFactory.attach_components(ent, [loc, fire])

def create_light(location):
    #entities with no name are no interactable (not added to the map as entities)
    ent = EntityFactory.create_entity('')
    loc = ComponentFactory.create_location(location)
    lig = ComponentFactory.create_light(1, 1, [1,2,3])
    EntityFactory.attach_components(ent, [loc, lig])
    
def fill_container(capacity, ctype):
    num_items = RandomEngine.number_in_range(0,capacity)
    items = []
    for i in range(num_items):
        ent = create_random_food_item()
        items.append(ent.entity_id)

    items.append(create_weapon(1).entity_id)
        
    return items

    

