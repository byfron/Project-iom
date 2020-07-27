extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick: Tick) -> int:
	var actor = tick.actor
	var actor_entity = EntityPool.get(actor.entity_id)
	var context = tick.blackboard.get('context')
	
	#Look for seen objects in memory that are still around!
	var memory = Utils.get_entity_memory(actor_entity)
	
	#cut down the num. of entities. Remove trees etc...
	print('Entities seen list:' , memory.entities_visited.size())
	
	for eid in memory.entities_visited:
		var state = memory.entities_visited[eid]
		
		#This is not very flexible IMHO
		#if entity was already EXPLORED, ignore it
		if state.value == 1:
			continue
			
		#make sure it's reachable
		var entity = EntityPool.get(eid)
		
		print('INTEREST IN:', entity.name)
		
		var entity_location = Utils.get_entity_location(entity)
		var path_manager = context.get_path_manager()
		var path = path_manager.compute_path(actor.coords, entity_location)
		if len(path) > 0:
			#Just go for the first if close enough
			memory.remembered_pos = entity_location
			memory.remembered_entity = entity
			
			#Randomly go idle and loose a turn thinking
			if randi()%2 > 0:
				return ERR_BUSY
				
			return OK
		
	return FAILED
