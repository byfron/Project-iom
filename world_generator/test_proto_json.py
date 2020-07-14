from ecs_utils import *
from google.protobuf.json_format import MessageToJson
import base64

import pdb


def message_to_json(entity):
    ent_json_msg = MessageToJson(entity)
    for comp in entity.components:

        pdb.set_trace()

        comp.data = loc_comp.ParseFromString(base64.b64decode(comp.data))

        com_json_msg = MessageToJson(comp)
        
        pdb.set_trace()


loc = ComponentFactory.create_location([10, 20])
door = ComponentFactory.create_door(False, False)
desc = ComponentFactory.create_description('Wooden door. Looks very sturdy')
entity = EntityFactory.create_entity("door", [loc, door, desc])

message_to_json(entity)
