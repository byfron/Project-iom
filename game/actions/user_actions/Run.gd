extends "UserAction.gd"
var path = []
	
func start_impl(context):
	$Anim.animation = "Running"
	#var node = context.get_entity_node(entity)
	#node.under_attack = false

#func on_finish(context):
	#Put back idle animation on exit
	#var node = context.get_entity_node(entity)
	#node.set_animation("Idle")
	#node.set_frame(0)
		
	#node.stop_ghosting()

func on_state_changed(action, context):
#func execute_impl(action, context):
	var tile = path.pop_front()
	if not tile:
		return
	
	#If our tile is under attack, moving is dodging roll!
	var node = context.get_entity_node(entity)
	if node.under_attack:
		#instantiate dodge action and execute it?
		$Anim.animation = "Dodge"
		node.switch_anim("Dodge")
		node.orientCharacterTowards(tile, true)
		#Make the actor face the contrary direction of movement
		
		node.under_attack = false
		
		#"Ghost" motion for dodging
		node.start_ghosting()
		
		if tile and context.is_walkable(tile):
			context.move_entity_to_tile(entity, tile)
			entity.components['location'].get_coord().set_x(tile.x)
			entity.components['location'].get_coord().set_y(tile.y)
		
	else:
		$Anim.animation = "Running"
		node.switch_anim("Running")
		node.orientCharacterTowards(tile)

		#var entities = context.get_entities_in_tile(tile)
		if tile and context.is_walkable(tile):
			context.move_entity_to_tile(entity, tile)
			entity.components['location'].get_coord().set_x(tile.x)
			entity.components['location'].get_coord().set_y(tile.y)
		
	
