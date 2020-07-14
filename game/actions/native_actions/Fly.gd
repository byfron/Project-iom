extends "res://game/actions/Action.gd"
tool

export var rotate = true
var tile_path = null
var curve = null

#TODO: make it static?
var ActionFactory = load('res://game/core/ActionFactory.gd').new()

func process_impl(context, turn_time):
	var node = context.get_entity_node(entity)
	var normalized_action_time = get_normalized_action_time(turn_time)
	var pos = curve.interpolate(0, normalized_action_time) 
	node.position = pos
	
	if rotate:
		node.rotation_degrees = normalized_action_time*2000
		
func on_state_changed(action, context):
	
	#TODO: update trajectory path on the fly to land in the player's head!
	
	#if true:#tile and context.is_walkable(tile):
	#	var node = context.get_entity_node(entity)
		#move towards the goal
		
	var tile = tile_path[current_state]
	entity.components['location'].get_coord().set_x(tile.x)
	entity.components['location'].get_coord().set_y(tile.y)
	
		#var pos = curve.interpolate(0, t)
		#t += 0.2
		
		#internal_pos.x += direction.x * strength
		#internal_pos.y += direction.y * strength
		#tile.x = round(internal_pos.x)
		#tile.y = round(internal_pos.y)
		
	#check for any obstacle in the trajectory and act acoordingly
	#if current_state > 0 and
	#	finish_action()
	
func on_finish(context):
	var explode_action = ActionFactory.create_explode_action(entity)
	SignalManager.emit_signal('send_action', explode_action)
	
	
	var tile = tile_path[-1]
	if tile in context._tile2entity:
		#TODO: damage entity. TODO. multiples entities here???
		#take the one that CAN be damaged!
		var damaged_entity = context._tile2entity[tile][0]
		var from_tile = tile_path[-2]
		var take_hit_action = ActionFactory.create_takehit_action(damaged_entity, from_tile, 10)
		SignalManager.emit_signal('send_action', take_hit_action)
	
