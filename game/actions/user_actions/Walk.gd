extends "UserAction.gd"
var path = []

func start_impl(context):
	$Anim.animation = "Walking"
	#var node = context.get_entity_node(entity)
	#node.under_attack = false

func on_finish(context):
	pass
	#Put back idle animation on exit
	#var node = context.get_entity_node(entity)
	#node.set_animation("Idle")
	#node.set_frame(0)
		
	#node.stop_ghosting()

func on_state_changed(action, context):

	var tile = path.pop_front()
	if not tile:
		finish_action()
		return

	#If our tile is under attack, moving is dodging roll!
	var node = context.get_entity_node(entity)
	tile = Vector3(tile.x, tile.y, node.coords.z)
	
	if false: #node.under_attack:
		#instantiate dodge action and execute it?
		$Anim.animation = "Dodge"
		node.set_animation("Dodge")
		node.orientCharacterTowards(tile, true)
		#Make the actor face the contrary direction of movement
		
		node.under_attack = false
		
		
		
		#"Ghost" motion for dodging
		node.start_ghosting()
		
		if tile and context.is_walkable(tile):
			context.move_entity_to_tile(entity, tile, true)
			entity.components['location'].get_coord().set_x(tile.x)
			entity.components['location'].get_coord().set_y(tile.y)
		
	else:
		$Anim.animation = "Walking"
		node.set_animation("Walking")
		node.orientCharacterTowards(tile)

		var frame_idx = node.get_frame_idx()
		#var entities = context.get_entities_in_tile(tile)
		if tile and context.is_walkable(tile) and frame_idx%2 == 1:
			context.move_entity_to_tile(entity, tile, true)
			entity.components['location'].get_coord().set_x(tile.x)
			entity.components['location'].get_coord().set_y(tile.y)
