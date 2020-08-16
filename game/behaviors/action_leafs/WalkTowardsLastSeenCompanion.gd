extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick: Tick) -> int:
	
	var context = tick.blackboard.get('context')
	
	#TODO: get rid of the blackboard memory, 
	#or copy the actor memory in the blacboard
	var memory = tick.blackboard.get('memory')
	var player_tile = null
	if memory:
		player_tile = memory.last_seen_companion
	else:
		return FAILED
	
	if player_tile == null:
		return FAILED
	
	var actor = tick.actor
	var path_manager = context.get_path_manager()
	var path = path_manager.compute_path(actor.coords, player_tile)
	if len(path) == 0:
		return FAILED
		
	if len(path) == 1:
		return OK
		
	var move_to_tile = path[1]
	var actor_entity = EntityPool.get(actor.entity_id)
	SignalManager.emit_signal('send_action', ActionFactory.create_run_action(actor_entity, [move_to_tile]))
	
	return ERR_BUSY
