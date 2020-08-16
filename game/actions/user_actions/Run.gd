extends "UserAction.gd"
var path = []
var sprinting = false
	
func start_impl(context):
	$Anim.animation = "Running"
	
	if sprinting:
		var node = context.get_entity_node(entity)
		node.start_ghosting()
	
	#var node = context.get_entity_node(entity)
	#node.under_attack = false

func on_finish(context):
	var node = context.get_entity_node(entity)
	node.stop_ghosting()
	pass
	#Put back idle animation on exit
	#var node = context.get_entity_node(entity)
	#node.set_animation("Idle")
	#node.set_frame(0)
		
	#node.stop_ghosting()
	
func consumes_turn():
	#if sprinting, we consume turn or not?
	#throw dice based on skills
	if sprinting:
		var skill_roll = DiceGenerator.roll_dices(1, 100)
		var stamina = entity.components['char_stats'].get_stamina()
		#it doesn't consume turn if the roll is less than our stamina
		return skill_roll > stamina
	else:
		return .consumes_turn()
		
#TODO: Refactor this as a sub-action node
func consume_stamina(context):
	var stamina_used = DiceGenerator.roll_dices(1, 4)
	var stamina = entity.components['char_stats'].get_stamina()
	var current_stamina = max(0, stamina - stamina_used)
	entity.components['char_stats'].set_stamina(current_stamina)
	
	if entity.id == context.player_entity_id:
		SignalManager.emit_signal("update_stamina", current_stamina)

func on_state_changed(action, context):
#func execute_impl(action, context):
	
	print('onStateChanged')
	
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
		
		consume_stamina(context)
		
		if tile and context.is_walkable(tile):
			context.move_entity_to_tile(entity, tile, true)
			entity.components['location'].get_coord().set_x(tile.x)
			entity.components['location'].get_coord().set_y(tile.y)
		
	else:
		$Anim.animation = "Running"
		node.set_animation("Running")
		node.orientCharacterTowards(tile)

		#var entities = context.get_entities_in_tile(tile)
		if tile and context.is_walkable(tile):
			
			if sprinting:
				consume_stamina(context)
			
			context.move_entity_to_tile(entity, tile, true)
			entity.components['location'].get_coord().set_x(tile.x)
			entity.components['location'].get_coord().set_y(tile.y)
		
	
			print('moving entity ', entity.name, ' to ', str(tile.x), ' ', str(tile.y))
			
	
