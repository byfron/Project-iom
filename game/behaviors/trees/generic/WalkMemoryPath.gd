extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick: Tick) -> int:
	
	var context = tick.blackboard.get('context')
	
	#TODO: get rid of the blackboard memory, 
	#or copy the actor memory in the blackboard
	var memory = tick.blackboard.get('memory')
	
	if memory:
		var path = memory.remembered_path
		if path:
			if len(path) == 1:
				return OK
		
			var move_to_tile = path[0]
			var actor_entity = EntityPool.get(tick.actor.entity_id)
			SignalManager.emit_signal('send_action', ActionFactory.create_run_action(actor_entity, [move_to_tile]))
	
			path.pop_front()
			
			return ERR_BUSY
			
	return FAILED
