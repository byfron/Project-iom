extends "res://addons/godot-behavior-tree-plugin/action.gd"

func find_patrol_location(max_dist, starting_tile, context):
	var location = null
	while not location:
		var angle = randi()%360+1
		var rnd_vec = (Vector2(1, 0) * max_dist).rotated(deg2rad(angle))
		var loc = starting_tile + Vector3(int(rnd_vec.x), int(rnd_vec.y), 0)
		#TODO: we should rather check that it's "REACHABLE"
		if context.is_walkable(loc):
			location = loc
		
	return location
		

func tick(tick: Tick) -> int:

	
	var actor = tick.actor
	var context = tick.blackboard.get('context')
	tick.blackboard.set('memory', actor.memory)
	
	#Store the original position if not there yet
	var starting_tile = tick.blackboard.get('starting_tile')
	
	if not starting_tile:
		tick.blackboard.set('starting_tile', actor.coords)
		starting_tile = actor.coords
		
	
	#Find a location to patrol around
	var max_dist_from_src = 10
	var location = find_patrol_location(max_dist_from_src, starting_tile, context)
	var path_manager = context.get_path_manager()
	var path = path_manager.compute_path(actor.coords, location)
	path.pop_front()
	
	actor.memory.remembered_path = path
	
	return OK
