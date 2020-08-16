extends "UserAction.gd"
var used_entity = null

func start_impl(context):
	var node = context._entity2node[entity.id]
	node.orientCharacterTowards(Utils.get_entity_location(used_entity))

func execute_impl(action, context):
	
	if "lock" in used_entity.components:
		#Check if we have the right key in the inventory
		#TODO: refactor
		var has_correct_key = false
		var stored_entities = entity.components['inventory'].get_stored_entities()
		for ent_id in stored_entities:
			var ent = EntityPool.get(ent_id)
			if ent.components.has('key'):
				var lock_key_code = used_entity.components['lock'].get_key_code()
				var key_code = ent.components['key'].get_key_code()
				if lock_key_code == key_code:
					has_correct_key = true
	
		if not has_correct_key:
			var criteria = []
			var lower_name = used_entity.name.to_lower()
			criteria.append('object_' + lower_name)
			SignalManager.emit_signal("query_dialog_system", entity, "OnOpen", criteria, used_entity)
		
			#If it's locked we shouldn't run the animation (or the sound)
			Utils.delete_children(self)
			return
	
	if "container" in used_entity.components:
		#context.world.info_panel.update()
		SignalManager.emit_signal("log_event", "You look into the " + used_entity.name)
		$SoundSubAction.sound = "OPEN_02"
		
	if "container" in used_entity.components:
		context.world.container_panel.fill_with_container(used_entity)
		context.world.show_container()
		$SoundSubAction.sound = "OPEN_02"
		
	if "stairs" in used_entity.components:
		#move character down
		var stairs_location = Utils.get_entity_location(used_entity)
		var z_offset = used_entity.components['stairs'].get_to_level()
		stairs_location.z += z_offset
		context.move_entity_to_tile(context.get_player_entity(), stairs_location)
		return
		
	#Refactor somewhere?
	if "door" in used_entity.components:
		$SoundSubAction.sound = "OPEN_01"
		var door = used_entity.components['door']
		var loc = used_entity.components['location']
		var pos = Vector3(loc.get_coord().get_x(), loc.get_coord().get_y(), loc.get_coord().get_z())
		if not door.get_open_closed():
			context.world.wlk_obstacles.erase(Vector2(pos.x, pos.y))
			context.world.fov_obstacles.erase(Vector2(pos.x, pos.y))
					
			#Change graphics in entity and node
			#TODO. Refactor somehow. Maybe create a state machine in actors/objects?
			#For the time being, we support just two states. Graphics IDs are always consecutive
			#if the door is closed, we increase 1. If it's open we decrease 1.
			
			var gid = used_entity.components['graphics'].get_graphics_id()
			used_entity.components['graphics'].set_graphics_id(gid-1)
			context.world.update_chunk_database(pos, GameEngine.TILEMAPSTACK.OBJECT, gid-1)
					
			#Find entity node to play sound
			#We could abstract this more? TODO: maybe move sound to Resource/SoundManager?
			if used_entity.id in context._entity2node:
				var node = context._entity2node[used_entity.id]
				node.update()

			#we should ALSO change the META layer!
			context.world.update_chunk_database(pos, GameEngine.TILEMAPSTACK.META, 0)

			SignalManager.emit_signal("log_event", "You open the door")
					
			door.set_open_closed(true)
		else:
			$SoundSubAction.sound = "OPEN_01"
			#TODO: make wlk and fov private and use a method instead that we pass the 3d vector
			context.world.wlk_obstacles[Vector2(pos.x, pos.y)] = 1
			context.world.fov_obstacles[Vector2(pos.x, pos.y)] = 2
			
			#we should ALSO change the META layer!
			context.world.update_chunk_database(pos, GameEngine.TILEMAPSTACK.META, 1)
			var gid = used_entity.components['graphics'].get_graphics_id()
			used_entity.components['graphics'].set_graphics_id(gid+1)
			context.world.update_chunk_database(pos, GameEngine.TILEMAPSTACK.OBJECT, gid+1)
					
			#Find entity node to play sound
			if used_entity.id in context._entity2node:
				var node = context._entity2node[used_entity.id]
				node.update()
				#node.forward_anim()
				#node.play_sound("CLOSE")
					
			door.set_open_closed(false)
			SignalManager.emit_signal("log_event", "You close the door")
					
		context.world.compute_fov([])
