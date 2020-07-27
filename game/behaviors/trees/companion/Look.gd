extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick: Tick) -> int:
	var actor = tick.actor
	var actor_entity = EntityPool.get(actor.entity_id)
	#Send RandomIdle action that does not consume turn
	SignalManager.emit_signal('send_action', ActionFactory.create_random_idle_action(actor_entity))
	
	#Look around for all entities in the field of view
	var fov_cones = Utils.compute_fov_cones_from_orientation(actor.current_orientation)
	var position = Vector2(actor.coords.x, actor.coords.y)
	var max_distance = 10 #TODO: check vision stats
	var entities = Utils.get_objects_in_fovcones(position, fov_cones, max_distance)
	
	#Send dialog signals for observed objects
	
	#Choose an object around and show interest
	#Maybe we can have a rank of interests in objects (utility?)
	
	#Behavior sub-Branch:
	#Go to object. Maybe interact? Try to open door.
	#Go to window. Look and comment about breaking it. 
	#Send comments only when there's interest in the object. Over a certain utility score. 
	
	#Actor memorizes all entities around him (exclude player)
	#TODO: May have different states: UNSEEN, EXPLORED
	var memory = Utils.get_entity_memory(actor_entity)
	
	#Find patterns. 
	#Plenty trees is a forest... 
	#Furniture and walls is a room
	
	var min_interest = 3
	
	var DISCOVERED = 0
	var EXPLORED = 1
	
	if len(entities) == 0:
		return FAILED
	
	for entity in entities:
		
		#distard entities with interest level under a threshold
		if 'interest' in entity.components:
			var interest = entity.components['interest'].get_interest()
			if interest > min_interest:
				if not memory.is_entity_visited(entity.id) and entity != GameEngine.context.get_player_entity():
					memory.add_entity_memory(entity.id, DISCOVERED, GameEngine.DEFAULT_ENTMEM_CLEAN_TURNS)
		
			
		
		#TODO: parse spaces?
#		var lower_name = entity.name.to_lower()
#		criteria.append('object_' + lower_name)

			
		
		
	
			
	#TODO: We can keep in memory the instances that we have already seen as well, 
	#and we avoid commenting stuff about them, until the memory expires
	#SignalManager.emit_signal("query_dialog_system", actor_entity, "onSee", criteria)
	return OK
	
#
#	pass
#
#
#	#TEST: Randomly walk around
#
#	var context = tick.blackboard.get('context')
#	var path_manager = context.get_path_manager()
#
#
#	var values = [-1, 0, 1]
#	var random_x = values[randi()%2]
#	var random_y = values[randi()%2]
#	#TODO: randomly choose a direction when the angle is 45 degrees
#	var move_to_tile = actor.coords
#	move_to_tile.x += random_x
#	move_to_tile.y += random_y
#
#	var actor_entity = EntityPool.get(actor.entity_id)
#	print('Sending walk action from behavior')
#	SignalManager.emit_signal('send_action', ActionFactory.create_walk_action(actor_entity, [move_to_tile]))
#
#	return ERR_BUSY
#
#	return OK
