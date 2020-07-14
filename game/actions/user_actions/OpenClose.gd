extends "UserAction.gd"
var used_entity = null

func start_impl(context):
	var node = context._entity2node[entity.id]
	node.orientCharacterTowards(Utils.get_entity_location(used_entity))

func execute_impl(action, context):
	
	if "container" in used_entity.components:
		context.world.info_panel.update()
		SignalManager.emit_signal("log_event", "You look into the " + used_entity.name)
		$SoundSubAction.sound = "OPEN_02"
		
	if "container" in used_entity.components:
		context.world.container_panel.fill_with_container(used_entity)
		context.world.show_container()
		$SoundSubAction.sound = "OPEN_02"
			
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
			if used_entity.components['graphics'].get_graphics_id() == 252:
				used_entity.components['graphics'].set_graphics_id(254)
				context.world.update_chunk_database(pos, 2, 254)
			if used_entity.components['graphics'].get_graphics_id() == 250:
				used_entity.components['graphics'].set_graphics_id(251)
				context.world.update_chunk_database(pos, 2, 251)
			if used_entity.components['graphics'].get_graphics_id() == 244:
				used_entity.components['graphics'].set_graphics_id(242)
				context.world.update_chunk_database(pos, 2, 242)
			if used_entity.components['graphics'].get_graphics_id() == 245:
				used_entity.components['graphics'].set_graphics_id(243)
				context.world.update_chunk_database(pos, 2, 243)
			###############################################################################################
					
			#Find entity node to play sound
			#We could abstract this more? TODO: maybe move sound to Resource/SoundManager?
			if used_entity.id in context._entity2node:
				var node = context._entity2node[used_entity.id]
				node.update()
				#node.play_sound("OPEN")
					
			#var tid = 254 #TODO this magic number can come from a json
								
			#2 is for OVERGROUND. WE should refactor the stack types somewhere
					
			#context.world.world_map.tilemap_controller.update_tilemap(pos, 2, tid)
			#we should ALSO change the META layer!
			context.world.update_chunk_database(pos, 4, 0)

			SignalManager.emit_signal("log_event", "You open the door")
					
			door.set_open_closed(true)
		else:
			$SoundSubAction.sound = "OPEN_01"
			#TODO: make wlk and fov private and use a method instead that we pass the 3d vector
			context.world.wlk_obstacles[Vector2(pos.x, pos.y)] = 1
			context.world.fov_obstacles[Vector2(pos.x, pos.y)] = 1
					
			#TODO: this should all GO SOMEHWERE
			#var tid = 252					
					
			#context.world.world_map.tilemap_controller.update_tilemap(pos, 2, tid)
			#we should ALSO change the META layer!
			context.world.update_chunk_database(pos, 4, 1)
			#Change graphics in entity and node
			#TODO. Refactor somehow. Maybe create a state machine in actors/objects?
			if used_entity.components['graphics'].get_graphics_id() == 254:
				used_entity.components['graphics'].set_graphics_id(252)
				context.world.update_chunk_database(pos, 2, 252)
			if used_entity.components['graphics'].get_graphics_id() == 251:
				used_entity.components['graphics'].set_graphics_id(250)
				context.world.update_chunk_database(pos, 2, 250)
					
			#Find entity node to play sound
			if used_entity.id in context._entity2node:
				var node = context._entity2node[used_entity.id]
				node.update()
				#node.forward_anim()
				#node.play_sound("CLOSE")
					
			door.set_open_closed(false)
			SignalManager.emit_signal("log_event", "You close the door")
					
		context.world.compute_fov([])
