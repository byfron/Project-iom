import json
import copy
import pdb
from ecs_utils import *

# class ClothingTemplate:


#TODO: refactor with abstract class all templates!
class ItemTemplate:
    item_map = {}    
    @staticmethod
    def initialize_item_map():
        config_file = 'config/items.json'
        with open(config_file, 'r') as fp:
            template_data = json.load(fp)
            for template in template_data['item_templates']:
                ItemTemplate.item_map[template['item_id']] = template
    
    @staticmethod
    def create_entity(item_id):
        if not ItemTemplate.item_map:
            ItemTemplate.initialize_item_map()

        if item_id not in ItemTemplate.item_map:
            print('obj_id %d not recognized as item' % item_id)
            return
        
        obj = copy.deepcopy(ItemTemplate.item_map[item_id])
        ent = EntityFactory.create_entity(obj['name'])
        del obj['name']
        del obj['item_id']

        module = __import__('ecs_utils')
        cls = getattr(module, 'ComponentFactory')
        comp_list = []
        for comp_name in obj:
            method_name = 'create_' + comp_name
            method = getattr(cls, method_name)
            comp_list.append(method(* obj[comp_name]))

        EntityFactory.attach_components(ent, comp_list)
        return ent

    
#TODO: lots of repeated code. Im sure we can do better
class FoodTemplate:
    food_map = {}
    @staticmethod
    def initialize_food_map():
        config_file = 'config/food.json'
        with open(config_file, 'r') as fp:
            template_data = json.load(fp)
            for template in template_data['food_templates']:
                FoodTemplate.food_map[template['food_id']] = template

    @staticmethod
    def create_entity(food_id):
        if not FoodTemplate.food_map:
            FoodTemplate.initialize_food_map()

        if food_id not in FoodTemplate.food_map:
            print('obj_id %d not recognized as food' % food_id)
            return
        
        obj = copy.deepcopy(FoodTemplate.food_map[food_id])
        ent = EntityFactory.create_entity(obj['name'])
        del obj['name']
        del obj['food_id']

        module = __import__('ecs_utils')
        cls = getattr(module, 'ComponentFactory')
        comp_list = []
        for comp_name in obj:
            method_name = 'create_' + comp_name
            method = getattr(cls, method_name)
            comp_list.append(method(* obj[comp_name]))

        EntityFactory.attach_components(ent, comp_list)
        return ent
    
class WeaponTemplate:
    weapon_map = {}
    @staticmethod
    def initialize_weapon_map():
        config_file = 'config/weapons.json'
        with open(config_file, 'r') as fp:
            template_data = json.load(fp)
            for template in template_data['weapon_templates']:
                WeaponTemplate.weapon_map[template['weapon_id']] = template
    
    @staticmethod
    def create_entity(weapon_id):
        if not WeaponTemplate.weapon_map:
            WeaponTemplate.initialize_weapon_map()
        
        if weapon_id not in WeaponTemplate.weapon_map:
            print('obj_id %d not recognized as object' % weapon_id)
            return

        obj = copy.deepcopy(WeaponTemplate.weapon_map[weapon_id])
        ent = EntityFactory.create_entity(obj['name'])
        del obj['name']
        del obj['weapon_id']

        module = __import__('ecs_utils')
        cls = getattr(module, 'ComponentFactory')

        comp_list = []
        for comp_name in obj:
            method_name = 'create_' + comp_name
            method = getattr(cls, method_name)
            print(obj[comp_name])
            comp_list.append(method(* obj[comp_name]))

        EntityFactory.attach_components(ent, comp_list)
        return ent

class ObjectTemplate:
    object_map = {}
    @staticmethod
    def initialize_object_map():
        config_file = 'config/objects.json'
        with open(config_file, 'r') as fp:
            template_data = json.load(fp)
            for template in template_data['object_templates']:
                ObjectTemplate.object_map[template['object_id']] = template

    @staticmethod
    def object_has_component(obj_id, comp_name):
        if not ObjectTemplate.object_map:
            ObjectTemplate.initialize_object_map()

        if obj_id not in ObjectTemplate.object_map:
            print('obj_id %d not recognized as object' % obj_id)
            return False

        obj = copy.deepcopy(ObjectTemplate.object_map[obj_id])
        if comp_name in obj:
            return True

        return False

    @staticmethod
    def object_get_volume(obj_id):
        if not ObjectTemplate.object_map:
            ObjectTemplate.initialize_object_map()

        if obj_id not in ObjectTemplate.object_map:
            print('obj_id %d not recognized as object' % obj_id)
            return None

        obj = copy.deepcopy(ObjectTemplate.object_map[obj_id])
        if 'volume' in obj:
            return obj['volume']
        return None
                
    @staticmethod
    def create_entity_with_location(obj_id, location, orientation=None):
        if not ObjectTemplate.object_map:
            ObjectTemplate.initialize_object_map()        
            
        if obj_id not in ObjectTemplate.object_map:
            print('obj_id %d not recognized as object' % obj_id)
            return
            
        obj = copy.deepcopy(ObjectTemplate.object_map[obj_id])
        ent = EntityFactory.create_entity(obj['name'])
        del obj['name']
        del obj['object_id']
        del obj['location']

        if orientation:
            del obj['orientation']
        
        module = __import__('ecs_utils')
        cls = getattr(module, 'ComponentFactory')

        comp_list = []
        for comp_name in obj:
            method_name = 'create_' + comp_name
            method = getattr(cls, method_name)

            if isinstance(obj[comp_name], list):
                comp_list.append(method(*obj[comp_name]))
            elif isinstance(obj[comp_name], dict):
                comp_list.append(method(**obj[comp_name]))
            else:
                assert(False)

        
        comp_list.append(ComponentFactory.create_location(location))#[location[1], location[0], location[2]]))

        if orientation:
            comp_list.append(ComponentFactory.create_orientation(orientation))
            
        EntityFactory.attach_components(ent, comp_list)
        return ent


class CharacterTemplate:

    character_map = {}
    
    @staticmethod
    def initialize_character_map():
        config_file = 'config/characters.json'
        with open(config_file, 'r') as fp:
            template_data = json.load(fp)
            for template in template_data['character_templates']:
                CharacterTemplate.character_map[template['character_id']] = template

    @staticmethod
    def create_entity_with_location(char_id, location):
        #TODO: this code is pretty much the same as above
        if not CharacterTemplate.character_map:
            CharacterTemplate.initialize_character_map()

        if char_id not in CharacterTemplate.character_map:
            print('char_id %d not recognized as character' % char_id)
            return

        char = copy.deepcopy(CharacterTemplate.character_map[char_id])
        ent = EntityFactory.create_entity(char['name'])
        print(char['name'])
        del char['name']
        del char['character_id']
        del char['location']

        module = __import__('ecs_utils')
        cls = getattr(module, 'ComponentFactory')

        comp_list = []
        for comp_name in char:
            method_name = 'create_' + comp_name
            method = getattr(cls, method_name)

            if isinstance(char[comp_name], list):
                comp_list.append(method(*char[comp_name]))
            elif isinstance(char[comp_name], dict):
                comp_list.append(method(**char[comp_name]))
            else:
                assert(False)
                
        comp_list.append(ComponentFactory.create_location(location))#[location[0], location[0], location[2]])) 
        EntityFactory.attach_components(ent, comp_list)
        return ent
