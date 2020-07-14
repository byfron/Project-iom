extends "UserAction.gd"
var weapon_entity = null
var attacked_tile = null
var attacked_entity = null

#TODO make this static
var NodeFactory = load('res://game/core/NodeFactory.gd').new()


#TODO: 
#"""
#I need to refactor all little bits of actions:
#	 * Take damage of type
#	 * Fly
#	 * Logging needs to be out: Maybe a ActionNotificationNode
#	 * etc...
#
#"""
func start_impl(context):
	attacked_entity = context.get_char_entity_in_tile(attacked_tile)
	var node = get_map_node(context)
	var aimed_node = context._entity2node[attacked_entity.id]
	node.orientCharacterTowards(aimed_node.coords)

func execute_impl(action, context):
	var node = context.get_entity_node(entity)
	var attacked_node = context.get_entity_node(attacked_entity)
	node.fire_weapon()
	
	#TODO: make blod splatting a separate action (that is instant, does not consume turn?)
	
	#Refactor this somewhere?
	var attacking_tile = Utils.get_entity_location(action.entity)
	var attacked_tile = Utils.get_entity_location(action.attacked_entity)
	var direction = (attacked_tile - attacking_tile).normalized()
	var tile_for_fx = attacked_node.coords + direction
	
	#TODO: Add metadata in the tiles more than just walkable. is_wall? is_water?
	if not context.is_walkable(tile_for_fx):
		var pos = Utils.getScreenCoordsTileCenter(tile_for_fx) - Vector2(16,16)
		var blood_node = NodeFactory.createFXNode(context, pos)
		context.world.set_actor_node(blood_node)
	
	
	#Check if there's a wall right behind the player to add a blood splat
	
