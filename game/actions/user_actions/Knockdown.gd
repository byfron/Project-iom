extends "UserAction.gd"
var ActionFactory = load('res://game/core/ActionFactory.gd').new()
var tile_path = null
var curve = null
var stop_motion = false

func start_impl(context):
	var node = context.get_entity_node(entity)
	
	#node.airborn = true

func check_for_collision(context, pos):
	var tile_tl = Utils.screenToTile(pos - Vector2(-32,-32))
	var tile_br = Utils.screenToTile(pos - Vector2(32,32))
	
	#TODO: check the 2x2
	return (not context.is_walkable(tile_tl)) or (not context.is_walkable(tile_br))

func process_impl(context, turn_time):
	if stop_motion:
		return
		
	var node = context.get_entity_node(entity)
	var naction_time = get_normalized_action_time(turn_time)
	var pos = curve.interpolate(0, naction_time)

			
	#we should consider as collision that the knockout srite is 64x64
	#so we should take an extra tile when checking for collisions depending on direction
	if check_for_collision(context, node.position):
			stop_motion = true
	else:	
		node.position = pos
	
func on_state_changed(action, context):
	if current_state < len(tile_path):
		#TODO this should be re-factored somewhere!
		var tile = tile_path[current_state]
			
		#check that the tile is not blocked
		if not context.is_walkable(tile):
			stop_motion = true
			return
			#current_state = num_states-1
			#return
			
		entity.components['location'].get_coord().set_x(tile.x)
		entity.components['location'].get_coord().set_y(tile.y)
		var node = context.get_entity_node(entity)
		context.remove_entity_from_tile(entity, node.coords)
		context.add_entity_to_tile(entity, tile)
		node.coords = tile
		
func on_finish(context):
	
	#We alter the pos 
	var node = context.get_entity_node(entity)
	node.refresh_position()
	return
	
#	var tile = tile_path[-1]
#	entity.components['location'].get_coord().set_x(tile.x)
#	entity.components['location'].get_coord().set_y(tile.y)
#	var node = context.get_entity_node(entity)
#	context.remove_entity_from_tile(entity, node.coords)
#	context.add_entity_to_tile(entity, tile)
#	node.coords = tile
	
	#node.airborn = false
	
	
	#TODO: make entity loose turn
	
	pass
	#TEST: if we land in water!
	#var node = context.get_entity_node(entity)
	#node.set_floating_state(true)
