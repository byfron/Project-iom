extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick: Tick) -> int:
	
	var context = tick.blackboard.get('context')
	var player_tile = context.get_current_tile()
	var path_manager = context.get_path_manager()
	var actor = tick.actor
	
	var line = Utils.get_line_coords(actor.coords, player_tile)
	
	#TODO: randomly choose a direction when the angle is 45 degrees
	
	var move_to_tile = line[1]
	var actor_entity = EntityPool.get(actor.entity_id)
	print('Sending walk action from behavior')
	SignalManager.emit_signal('send_action', ActionFactory.create_walk_action(actor_entity, [move_to_tile]))

	return ERR_BUSY
