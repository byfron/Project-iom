extends "res://addons/godot-behavior-tree-plugin/action.gd"
var ActionFactory = load('res://game/core/ActionFactory.gd').new()

# Leaf Node
func tick(tick: Tick) -> int:
	var context = tick.blackboard.get('context')
	var player_tile = context.get_current_tile()
	var path_manager = context.get_path_manager()
	var actor = tick.actor
	
	#If there's direct sight with entity to follow, 
	var distance = (player_tile - actor.coords).length()
	var manhattan_dist = Utils.manhattan_dist(player_tile, actor.coords)
	if manhattan_dist <= 1:
		return OK
	
	var step = (player_tile - actor.coords) / (distance)
	var move_to_tile = actor.coords + Vector3(round(step.x), round(step.y), round(step.z))
	var actor_entity = EntityPool.get(actor.entity_id)
	SignalManager.emit_signal('send_action', ActionFactory.create_run_action(actor_entity, [move_to_tile]))
	#var path = path_manager.compute_path(actor.coords, player_tile)
	#if len(path) > 0:
	#SignalManager.emit_signal('send_action', ActionFactory.create_follow_action(actor.entity_id, path, context.player_entity_id))
	#	return FAILED
		
	return FAILED
