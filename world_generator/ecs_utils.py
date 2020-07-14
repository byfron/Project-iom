import uuid
import sys
sys.path.append('../proto/')
import base64
import ecs_pb2, world_pb2
import pdb
import json
import map_globals

#from entity_creators import fill_container
#import base64

#TODO: This may better be in a json, as well as the relationship actions, components?
class ActionEnum:
    LOOK = 1
    TALK = 2
    ATTACK = 3
    OPEN = 4
    CLOSE = 4
    TAKE = 5
    WIELD = 6
    EQUIP = 7
    DROP = 8
    

class MapUtils:
    @staticmethod
    def create_tilemap(name, ttype, tl, br, level, data):
        ctl = world_pb2.PBMapCoordinate(x=tl[0], y=tl[1], z=level)
        cbr = world_pb2.PBMapCoordinate(x=br[0], y=br[1], z=level)
        rect = world_pb2.PBRect(top_left=ctl, bottom_right=cbr)
        tilemap = world_pb2.PBTilemap(name=name, type=ttype, rect=rect, level=level, data=data)
        return tilemap

class ActionFactory:
    @staticmethod
    def create_action(aid, name, ctype, desc, atype, states, execute, animation, priority, auto, ttime):
        return ecs_pb2.PBAction(action_id=aid, name=name, component_type=ctype, description=desc, type=atype, states=states, execute=execute, animation=animation, priority=priority, auto=auto, turn_time=ttime)
    
    @staticmethod
    def create_actions():
        config_file = 'config/actions.json'
        actions = []
        with open(config_file, 'r') as fp:
            actions_data = json.load(fp)
            for actiond in actions_data['actions']:

                states = [0]
                execute = 0
                priority = 0
                animation = ''
                auto = False
                ttime = 0.1
                if 'states' in actiond:
                    states = actiond['states']
                    execute = actiond['execute']
                    animation = actiond['animation']

                if 'priority' in actiond:
                    priority = actiond['priority']

                if 'auto' in actiond:
                    auto = actiond['auto']

                if 'turn_time' in actiond:
                    ttime = actiond['turn_time']
                    
                action = ActionFactory.create_action(actiond['id'], actiond['name'], actiond['components'], actiond['description'], actiond['type'], states, execute, animation, priority, auto, ttime)

                if 'range' in actiond:
                    action.range = actiond['range']
                    
                actions.append(action)
        EntityFactory.entity_pool.actions.extend(actions)

class EntityFactory:
    entity_pool = ecs_pb2.PBEntityPool()

    @staticmethod
    def dump_entity_pool(filename):
        world_file = open(filename, "wb")
        world_file.write(base64.b64encode(EntityFactory.entity_pool.SerializeToString()))        
        world_file.close()        
    
    @staticmethod
    def create_entity(name, components=[]):
        entity_id = str(uuid.uuid4())
        EntityFactory.entity_pool.entities[entity_id].entity_id = entity_id
        EntityFactory.entity_pool.entities[entity_id].name = name
        EntityFactory.entity_pool.entities[entity_id].components.extend(components)
        return EntityFactory.entity_pool.entities[entity_id]

    @staticmethod
    def attach_components(entity, components):
        EntityFactory.entity_pool.entities[entity.entity_id].components.extend(components)
    
class ComponentFactory:
    @staticmethod
    def create_component(ctype, comp):
        data = base64.b64encode(comp.SerializeToString())
        return ecs_pb2.PBComponent(type=ctype, data=data)

    @staticmethod
    def create_item(weight, itype):
        comp = ecs_pb2.ItemComponent(weight=weight, itype=itype)
        return ComponentFactory.create_component('item', comp)
    
    @staticmethod
    def create_location(coords):
        try:
            map_coord = world_pb2.PBMapCoordinate(x=coords[0], y=coords[1], z=coords[2])
        except:
            pdb.set_trace()
        comp = ecs_pb2.LocationComponent(coord = map_coord)
        return ComponentFactory.create_component('location', comp)

    @staticmethod
    def create_movement(*args):
        arglist = list(args)
        speed = arglist[0]
        comp = ecs_pb2.MovementComponent(speed=speed)
        return ComponentFactory.create_component('movement', comp)    

    @staticmethod
    def create_dialog(*args):
        arglist = list(args)
        script = arglist[0]
        comp = ecs_pb2.DialogComponent(script=script)
        return ComponentFactory.create_component('dialog', comp)

    @staticmethod
    def create_throwable(*args):
        arglist = list(args)
        weight_factor = arglist[0]
        comp = ecs_pb2.ThrowableComponent(weight_factor=weight_factor)
        return ComponentFactory.create_component('throwable', comp)
        pass
    
    @staticmethod
    def create_stairs(*args):
        arglist = list(args)
        level = arglist[0]
        comp = ecs_pb2.StairsComponent(to_level=level)
        return ComponentFactory.create_component('stairs', comp)
    
    @staticmethod
    def create_behavior(*args):
        arglist = list(args)
        script = arglist[0]
        comp = ecs_pb2.BehaviorComponent(script=script)
        return ComponentFactory.create_component('behavior', comp)
    
    @staticmethod
    def create_initiative(*args):
        arglist = list(args)
        initiative = arglist[0]
        comp = ecs_pb2.InitiativeComponent(initiative=initiative)
        return ComponentFactory.create_component('initiative', comp)    

    @staticmethod
    def create_description(*args):
        arglist = list(args)
        desc = arglist[0]
        comp = ecs_pb2.DescriptionComponent(description=desc)
        return ComponentFactory.create_component('description', comp)

    @staticmethod
    def create_weapon(*args):
        arglist = list(args)
        wtype = arglist[0]
        damage = arglist[1]
        wrange = arglist[2]
        use_cost = arglist[3]
        apr = arglist[4]
        rc = arglist[5]
        comp = ecs_pb2.WeaponComponent(weapon_type=wtype, damage_roll=damage, range=wrange, use_cost=use_cost, attacks_per_round=apr, reload_cost=rc)
        return ComponentFactory.create_component('weapon', comp)

    @staticmethod
    def create_food(*args):
        arglist = list(args)
        nutrition = arglist[0]
        comp = ecs_pb2.FoodComponent(nutrition=nutrition)
        return ComponentFactory.create_component('food', comp)
    
    @staticmethod
    def create_character(*args):
        arglist = list(args)
        name = arglist[0]
        gender = arglist[1]
        level = arglist[2]
        exp = arglist[3]
        comp = ecs_pb2.CharacterComponent(name=name, gender=gender, level=level, experience=exp)
        return ComponentFactory.create_component('character', comp)

    @staticmethod
    def create_char_stats(*args):
        arglist = list(args)
        health = arglist[0]
        stamina = arglist[1]
        mana = arglist[2]
        sanity = arglist[3]
        comp = ecs_pb2.CharStatsComponent(health=health, stamina=stamina, mana=mana, sanity=sanity)
        return ComponentFactory.create_component('char_stats', comp)

    @staticmethod
    def create_volume(*args):
        arglist = list(args)
        height = arglist[0]
        comp = ecs_pb2.VolumeComponent(height=height)
        return ComponentFactory.create_component('volume', comp)

    @staticmethod
    def create_char_status(*args):
        arglist = list(args)
        crouching = arglist[0]
        running = arglist[1]
        bleeding = arglist[2]
        poisoned = arglist[3]
        comp = ecs_pb2.CharStatusComponent(crouching=crouching, running=running, bleeding=bleeding, poisoned=poisoned)
        return ComponentFactory.create_component('char_status', comp)
    
    @staticmethod
    def create_main_character(*args):
        arglist = list(args)
        name = arglist[0]
        gender = arglist[1]
        level = arglist[2]
        exp = arglist[3]
        comp = ecs_pb2.MainCharacterComponent(name=name, gender=gender, level=level, experience=exp)
        return ComponentFactory.create_component('main_character', comp)
        
    @staticmethod
    def create_container(*args):
        from entity_creators import fill_container
        arglist = list(args)
        capacity = arglist[0]
        container_type = arglist[1]
        entities = fill_container(capacity, container_type)        
        comp = ecs_pb2.ContainerComponent(capacity=capacity, type=container_type,
                                          entities=entities)
        return ComponentFactory.create_component("container", comp)

    #This method receives a dict, not an array
    @staticmethod
    def create_skills(**args):
        skill_map = args
        comp = ecs_pb2.SkillsComponent(skill_map=skill_map)
        return ComponentFactory.create_component("skills", comp)


    @staticmethod
    def create_fire(*args):
        arglist = list(args)
        power = arglist[0]
        if len(arglist) > 1:
            duration = arglist[1]
            comp = ecs_pb2.FireComponent(fire_power=power, fire_duration=duration)
        else:
            comp = ecs_pb2.FireComponent(fire_power=power)
            
        return ComponentFactory.create_component("fire", comp)
    
    @staticmethod
    def create_dialog(*args):
        arglist = list(args)
        dialog_states = []
        for state in arglist:
            dialog_states.append(ecs_pb2.DialogState(id=state['id'], script=state['script']))          
        comp = ecs_pb2.DialogComponent(dialog_states=dialog_states)
        return ComponentFactory.create_component("dialog", comp)
    
    @staticmethod
    def create_inventory(*args):
        arglist = list(args)
        capacity = arglist[0]
        comp = ecs_pb2.InventoryComponent(capacity=capacity, stored_entities=[], weilded_in_main_hand='', weilded_in_secondary_hand='', equiped_in_head='', equiped_in_chest='', equiped_in_hands='', equiped_in_legs='', equiped_misc='')
        return ComponentFactory.create_component("inventory", comp)

    @staticmethod
    def create_inventory_with_stuff(capacity, stored_entities, wielded_in_main_hand):
        comp = ecs_pb2.InventoryComponent(capacity=capacity, stored_entities=stored_entities, weilded_in_main_hand=wielded_in_main_hand, weilded_in_secondary_hand='', equiped_in_head='', equiped_in_chest='', equiped_in_hands='', equiped_in_legs='', equiped_misc='')
        return ComponentFactory.create_component("inventory", comp)
    
    @staticmethod
    def create_light(*args):
        comp = ecs_pb2.LightComponent(intensity=1, size=1, color=[255,255,255])
        return ComponentFactory.create_component("light", comp)
    
    @staticmethod
    def create_rest_spot(*args):
        arglist = list(args)
        pass    

    @staticmethod
    def create_device(*args):
        arglist = list(args)       
        pass

    @staticmethod
    def create_sound(**args):
        sound_map = args
        comp = ecs_pb2.SoundComponent(sound_map=sound_map)
        return ComponentFactory.create_component("sound", comp)
    
    @staticmethod
    def create_graphics(*args):
        #TODO: maybe using kargs we could directly pass it to the constructor!!
        arglist = list(args)
        sx = arglist[0]
        sy = arglist[1]
        gid = arglist[2]
        gtype = 0
        if len(arglist) > 3:
            gtype = arglist[3]
            
        comp = ecs_pb2.GraphicsComponent(size_x=sx, size_y=sy,graphics_id=gid,gtype=gtype)
        return ComponentFactory.create_component('graphics', comp)
        
    @staticmethod
    def create_chunk(x, y, z, tilemaps):        
        chunk_coord = world_pb2.PBMapCoordinate(x=x, y=y, z=z)
        chunk = world_pb2.PBWorldChunk(coord=chunk_coord, tilemap=tilemaps)
        comp = ecs_pb2.ChunkComponent(chunk=chunk)
        return ComponentFactory.create_component('chunk', comp)

    @staticmethod
    def create_door(locked, open_closed):
        comp = ecs_pb2.DoorComponent(locked=locked, open_closed=open_closed)
        return ComponentFactory.create_component('door', comp)
