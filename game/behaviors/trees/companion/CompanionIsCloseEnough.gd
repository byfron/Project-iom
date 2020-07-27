extends "res://addons/godot-behavior-tree-plugin/condition.gd"

func tick(tick: Tick) -> int:
	var context = tick.blackboard.get('context')
	var player_tile = context.get_current_tile()
	var path_manager = context.get_path_manager()
	var actor = tick.actor
	
	#If there's direct sight with entity to follow, 
	var distance = (player_tile - actor.coords).length()
	var manhattan_dist = Utils.manhattan_dist(player_tile, actor.coords)
	if manhattan_dist <= 5:
		return OK
		
	return FAILED
