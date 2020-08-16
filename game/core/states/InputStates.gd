extends Node

class InputState extends "res://game/utils/FSM.gd".FSMState:
	var _selected_entity = null
	var _selected_tile = null
	var _action = null
	var _explicit = true
	func _init():
		SignalManager.connect("unselect_entity", self, "unselect_entity")
		pass
		
	func unselect_entity():
		if _selected_entity:
			GameEngine.context.unselect_entity(_selected_entity)
			_selected_entity = null
		
	func update_action_info(entity):
		var action_name = ''
		if _action:
			action_name = _action.action_name
			
		var text = ''
		if entity:
			text = action_name + ' ' + entity.name
		else:
			text = action_name + '...'
		
		GameEngine.context.world.top_bar.update_action_text(text)
		
	func on_enter():
		pass
		
	func on_exit():
		pass
	func _process(delta):
		pass
		
	func left_click(event):
		return event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT 
		
	func process_mouse_input(event):
		_selected_tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
		var entities = GameEngine.context.get_entities_in_2Dtile_plevel(_selected_tile)
		if entities:
			if _selected_entity:
				unselect_entity()
				
			var first_ent = entities.front()
			_selected_entity = first_ent
			GameEngine.context.select_entity(first_ent)
			
			#When selecting an entity (mouse over) we should change state so that if the 
			#player clicks, the action is executed. We only do this if there's no explictly selected
			#action
			if not _explicit:
				var action_id = ActionFactory.create_default_action_id(_selected_tile)
				if action_id:
					#TODO: highlight_action signal can refer to both the button and the overlay!
					SignalManager.emit_signal('highlight_action_button', action_id)
					GameEngine.state_manager.process_action(action_id, false)
				
				GameEngine.context.unselect_tile()

		else:
			#GameEngine.state_manager._fsm.emit('cancel_state')w
			if _selected_entity:
				GameEngine.context.unselect_entity(_selected_entity)
				_selected_entity = null
			GameEngine.context.select_tile(_selected_tile)
			
			
		pass
		
		update_action_info(_selected_entity)
		
	func process_keyboard_input(event, input_manager):
		if input_manager.is_movement_event(event):
			input_manager.process_movement_event(event)
			GameEngine.state_manager._fsm.emit('cancel_state')

# Default state
# State when no action is selected. Mainly handles player movement
class DefaultInputState extends InputState:
	
	func on_enter():
		#Unselects any entity when we switch to default
		#SignalManager.emit_signal('unselect_entity')
		var node = GameEngine.context.get_player_node()
		node.reset_statuses()
		pass
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
		if (event is InputEventMouseButton && event.pressed):
			var pentity = null
			if (event.button_index == BUTTON_LEFT):
				pentity = GameEngine.context.get_player_entity()
			elif (event.button_index == BUTTON_RIGHT):
				pentity = GameEngine.context.get_companion_entity()
			else:
				assert(false)
			
			if not _selected_entity:
				if event.button_index == BUTTON_RIGHT:
					GameEngine.get_overlay_layer().place_floor_marker(_selected_tile)

				#walk/sneak/sprint
				
				var src = Utils.get_entity_location(pentity)
				var path = GameEngine.context.compute_path(src, _selected_tile)
				var action = ActionFactory.create_movement_action(pentity, path)
				SignalManager.emit_signal('send_action', action)
			else:

				#_action = ActionFactory.create_use_action(pentity, _selected_entity)
				#if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
				#var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
				SignalManager.emit_signal('send_action', _action)
				update_action_info(_selected_entity)
		
	func process_keyboard_input(event, input_manager):
		if input_manager.is_movement_event(event):
			input_manager.process_movement_event(event)
		
		
class SinDefaultInputState extends InputState:
	func on_enter():
		.on_enter()
		
		var pentity = GameEngine.context.get_player_entity()
		var location = Utils.get_entity_location(pentity)
		
		#TODO: Make an action to show sin (probably takes turns)
		#Show sin character
		location.y += 1
		location.x += 1
		GameEngine.context.show_sin_character(location)
		
		#create beam in main player
		#var node = GameEngine.context.get_player_node()
		#var beam = load("res://game/fx/LightBeam.tscn").instance()
		#beam.set_name("LightBeam")
		#beam.set_as_toplevel(true)
		#beam.src_node = node
		#beam.dst_node = GameEngine.context.get_companion_node()
		#node.add_child(beam)
		
		#Send agony action
		_action = ActionFactory.create_agony_action(pentity)
		SignalManager.emit_signal('send_action', _action)
		
	func on_exit():
		
		#GameEngine.context.hide_sin_character()
		#var pentity = GameEngine.context.get_player_entity()
		#var rnd_idle = ActionFactory.create_random_idle_action(pentity)
		#SignalManager.emit_signal('interrupt_action', pentity.id, rnd_idle, _action)
		pass
		
		
		
		#Remove beam node. Maybe this should go to player actor scene
		#var node = GameEngine.context.get_player_node()
		#var light_beam = node.find_node("LightBeam", false, false)
		#node.remove_child(light_beam)
		#light_beam.queue_free()
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
		if (event is InputEventMouseButton && event.pressed):
			var pentity = null
			if (event.button_index == BUTTON_LEFT):
				pentity = GameEngine.context.get_companion_entity()
				var src = Utils.get_entity_location(pentity)
				var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
				var path = GameEngine.context.compute_path(src, tile)
				var action = ActionFactory.create_levitate_action(pentity, path)
				SignalManager.emit_signal('send_action', action)
		
	func process_keyboard_input(event, input_manager):
		.process_keyboard_input(event, input_manager)

class DeadState extends InputState:
	func on_enter():
		GameEngine.context.world.fade_to_black()
		
	func process_mouse_input(event):
		pass
		
	func process_keyboard_input(event, input_manager):
		pass
		
class SinMagicInputState extends InputState:
	func on_enter():
		.on_enter()
		
		#TODO display range of attack
		var centity = GameEngine.context.get_companion_entity()
		var radius = 5
		GameEngine.get_overlay_layer().display_range(Utils.get_entity_location(centity), radius)
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
		if (event is InputEventMouseButton && event.pressed):
			var pentity = null
			if (event.button_index == BUTTON_LEFT):
				pass
		
# State when any attack button is pressed. Displays overlays for the different
# standard attacks (melee, ranged, etc...) and generates the attack action
class AttackInputState extends InputState:
	
	var aim_action_sent = false
	
	func on_enter():
		var pentity = GameEngine.context.get_player_entity()
		#_action = 
		
		#TODO: We may change the verb depending on the weapon wielded
		.on_enter()
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
		
		#TODO: This state is really a mess
		
		#If the action was not explicit, exit as soon as there's no entity selected
		if not _explicit and not _selected_entity:
			GameEngine.state_manager._fsm.emit('cancel_state')
			return
			
		
		#If the weapon is ranged, we should change to "range mode"
		var pentity = GameEngine.context.get_player_entity()
		#var is_ranged = Utils.weapon_equipped_is_ranged(pentity)
		
		
		var equipped_entity = Utils.get_entity_weilded_weapon(pentity)
		
		#by default melee (no weapon) range 1
		var wrange = 1
		var wtype = 3 
		
		if equipped_entity:
			var wcomponent = Utils.get_component(equipped_entity, 'weapon')
			if wcomponent:
				wrange = wcomponent.get_range()
				wtype = wcomponent.get_weapon_type()
		
		#TODO: from weapon type get the action
		# 2_hands_melee
		# 1_hand_melee
		# magic
		# gun_ranged
		
		
		
		if wrange > 1:
			
			#Send aim action?
			#if not aim_action_sent:
			#TODO: We are sending actions continuously! maybe only when we change tiles!
			var action = null
			#if _selected_entity:
			if wtype == 1: #Ranged firearm
				action = ActionFactory.create_aim_action(pentity, _selected_tile)
			#elif wtype == 2:
			#	action = ActionFactory.create_magic_aim_action(pentity, _selected_entity)
			else:
				assert(false)
					
			action._consumes_turn = false
			SignalManager.emit_signal('send_action', action)
				
		if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
			var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
			
			var action = null
			if wtype == 1: #Ranged firearm
				action = ActionFactory.create_ranged_attack_action(pentity, tile)
			elif wtype == 2:
				action = ActionFactory.create_magic_attack_action(pentity, tile)
			else:
				action = ActionFactory.create_melee_attack_action(pentity, tile)
				
			SignalManager.emit_signal('send_action', action)

	func process_keyboard_input(event, input_manager):
		.process_keyboard_input(event, input_manager)

class SprintInputState extends DefaultInputState:
	func on_enter():
		var pentity = GameEngine.context.get_player_entity()
		var char_status = Utils.get_component(pentity, "char_status")
		char_status.set_sprinting(true)
		.on_enter()
		
	func on_exit():
		var pentity = GameEngine.context.get_player_entity()
		var char_status = Utils.get_component(pentity, "char_status")
		char_status.set_sprinting(false)
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
	func process_keyboard_input(event, input_manager):
		.process_keyboard_input(event, input_manager)
		
class InvestigateInputState extends DefaultInputState:
	func process_mouse_input(event):
		.process_mouse_input(event)
		
		if _selected_entity and left_click(event):
			var pentity = GameEngine.context.get_player_entity()
			var criteria = []
			var lower_name = _selected_entity.name.to_lower()
			criteria.append('object_' + lower_name)
			SignalManager.emit_signal("query_dialog_system", pentity, "OnInvestigate", criteria, _selected_entity)

class CrouchInputState extends DefaultInputState:
	func on_enter():
		var pentity = GameEngine.context.get_player_entity()
		var char_status = Utils.get_component(pentity, "char_status")
		char_status.set_crouching(true)
		
		#Unselects any entity when we switch to default
		SignalManager.emit_signal('unselect_entity')
		_action = ActionFactory.create_crouch_action(pentity)
		SignalManager.emit_signal('send_action', _action)
		
		#enable new fov for 1 meter height!
		GameEngine.context._height_sight = 1
		GameEngine.context.world.compute_fov([])
		
	func on_exit():
		var pentity = GameEngine.context.get_player_entity()
		var char_status = Utils.get_component(pentity, "char_status")
		char_status.set_crouching(false)
		
		_action = ActionFactory.create_stand_action(pentity)
		SignalManager.emit_signal('send_action', _action)
		
		GameEngine.context._height_sight = 2
		GameEngine.context.world.compute_fov([])
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
#		if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
#			var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
#			var pentity = GameEngine.context.get_player_entity()
#			var path = GameEngine.context.compute_player_path(tile)
#			_action = ActionFactory.create_sneak_action(pentity, path)
#			_action.num_states = len(path)
#			SignalManager.emit_signal('send_action', _action)
		
	func process_keyboard_input(event, input_manager):
		if input_manager.is_movement_event(event):
			input_manager.process_movement_event(event)

class UseInputState extends InputState:
	func process_mouse_input(event):
		.process_mouse_input(event)
		if _selected_entity and left_click(event):
			var pentity = GameEngine.context.get_player_entity()
			_action = ActionFactory.create_use_action(pentity, _selected_entity)
			SignalManager.emit_signal('send_action', _action)
			#update_action_info(_selected_entity)
