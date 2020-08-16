extends Node
var ActionFactory = load('res://game/core/ActionFactory.gd').new()

tool
var weapon_entity = null
var success_rate = 70

func start(action, context):
	var node = action.get_map_node(context)
	node.orientCharacterTowards(action.attacked_tile)

func on_state_changed(action, context):
	
	#show meta icon for telegraphed attacks
	if action.entity != context.get_player_entity():
		if action.current_state == action.execution_state - 1:
			var node = action.get_map_node(context)
			#node.show_meta_tele_attack()
			
			#TODO: chatting enemies: needs to be more sophisticatred
			#node.chat_balloon.show()
			
			#GameEngine.get_overlay_layer().display_motion_grid(action.attacked_tile)
			
			#Mark tile/entity as "attacked"
			#TODO: maybe better in a status component
			
			#marked all nodes in the tile(s) under attack
			var entities = context.get_entities_in_tile(action.attacked_tile)
			
			for ent in entities:
				if ent == context.get_player_entity():
					var attacked_node = context.get_entity_node(ent)
					attacked_node.under_attack = true
			
			
		else:
			var node = action.get_map_node(context)
			#node.chat_balloon.hide()
			#node.hide_meta()
	
func process(context, delta):
	pass

func execute_impl(action, context):
	
	var attacking_node = context._entity2node[action.entity.id]
	
	#Attack whatever "character" in the tile and whiff if there's nothing
	if action.attacked_tile in context._tile2entity:
		var entity_list = context._tile2entity[action.attacked_tile]
		var damage = Utils.compute_punch_damage_roll(action.entity)
		#var damage = BRP.damage_roll("1D6")
		for ent in entity_list:
			
			#TODO: ONLY if ent is a character right!!!?
			
			var take_hit_action = ActionFactory.create_takehit_action(ent, Utils.get_entity_location(action.entity), damage)
			take_hit_action.damage = damage
			SignalManager.emit_signal('send_action', take_hit_action)
			
			
			#if the enemy is frozen destroy it
			#if ent.status == 'frozen':
			#var attacked_node = context._entity2node[ent.id]
			#attacked_node.explode()
			
			
			
			#Mark behavior tree to react to the attack
			if ent.id in context.behavior_map:
				var beh = context.behavior_map[ent.id]
				beh.onEvent("attacked", action.entity.id)
			
	else:
		pass
		#whiff
#
#
#
#	if action.attacked_entity.id in context._entity2node:
#		var attacked_node = context._entity2node[action.attacked_entity.id]
#		#attacking_node.orientCharacterTowards(attacked_node.coords)
#
#		if true:#BRP.skill_roll(success_rate):
#
#			attacked_node.select(false)
#
#			var damage_roll_code = "1D6"
#			if weapon_entity:
#				damage_roll_code = weapon_entity.components['weapon'].get_damage_roll()
#			else:
#				pass
#				#damage_roll_code = Utils.get_wrestling_damage_roll()
#
#			var damage = BRP.damage_roll(damage_roll_code)
#
#			attacking_node.melee_attack(attacked_node)
#
#
#			#TEST ####################################################3
#			#TODO move to the factory maybe
#			var knockdown = false
#			if knockdown:
#				var attacking_tile = Utils.get_entity_location(action.entity)
#				attacked_node.orientCharacterTowards(attacking_tile)
#
#
#				var attacked_tile = Utils.get_entity_location(action.attacked_entity)
#				#knockdown X tiles in the direction of the attack
#				var direction = (attacked_tile - attacking_tile).normalized()
#				var dst_tile = attacked_tile + direction*3
#				dst_tile.x = int(dst_tile.x)
#				dst_tile.y = int(dst_tile.y)
#				var tile_path = Utils.get_line_coords(attacked_tile, dst_tile)
#
#				#Compute throw curve of the trajectory
#				var throw_curve = Curve2D.new()
#				var src_pos = Utils.getScreenCoordsTileCenter(tile_path[0])
#				var dst_pos = Utils.getScreenCoordsTileCenter(tile_path[-1])
#				throw_curve.add_point(src_pos)
#				throw_curve.add_point(dst_pos)
#
#
#				var knockdown_action = ActionFactory.create_knockdown_action(action.attacked_entity, tile_path, throw_curve)
#				SignalManager.emit_signal('send_action', knockdown_action)
#			else:
#
#
#
#				#create take hit action
#				var take_hit_action = ActionFactory.create_takehit_action(action.attacked_entity, Utils.get_entity_location(action.entity), damage)
#				SignalManager.emit_signal('send_action', take_hit_action)
#
#			#var take_hit_action = ActionFactory.create_knockdown_action(action.attacked_entity, Utils.get_entity_location(action.entity), damage)
#			#SignalManager.emit_signal('send_action', take_hit_action)
#
#
#			#context.world.debug_panel.add_map_entry(entity.id, "attacking")
#
#			#if the actor is NOT the player, we update the behavior tree
#			#we can send a signal to the behavior tree
#			if action.attacked_entity.id in context.behavior_map:
#				var beh = context.behavior_map[action.attacked_entity.id]
#				beh.onEvent("attacked", action.entity.id)
#
#			Utils.apply_damage(action.attacked_entity, damage)
#			if action.attacked_entity == context.get_player_entity():
#				var health = action.entity.components['char_stats'].get_health()
#				SignalManager.emit_signal("update_player_health", health)
#
#			SignalManager.emit_signal("log_event", "Hit enemy!")
#		else:
#			attacked_node.miss_attack()
#			SignalManager.emit_signal("log_event", "Missed attack!")
