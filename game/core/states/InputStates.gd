extends Node

class InputState extends "res://game/utils/FSM.gd".FSMState:
	var _selected_entity = null
	var _action = null
	func _init():
		pass
		
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
	func process_mouse_input(event):
		var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
		var entities = GameEngine.context.get_entities_in_2Dtile_plevel(tile)
		if entities:
			if _selected_entity:
				GameEngine.context.unselect_entity(_selected_entity)
			var first_ent = entities.front()
			_selected_entity = first_ent
			GameEngine.context.select_entity(first_ent)
			
			#When selecting an entity (mouse over) we should change state so that if the 
			#player clicks, the action is executed
			var default_action = ActionFactory.create_default_action_id(tile)
			if default_action:
				#TODO: highlight_action signal can refer to both the button and the overlay!
				SignalManager.emit_signal('highlight_action_button', default_action)
				GameEngine.state_manager._fsm.emit('attack_action')
				
			GameEngine.context.unselect_tile()

		else:
			GameEngine.state_manager._fsm.emit('cancel_state')
			if _selected_entity:
				GameEngine.context.unselect_entity(_selected_entity)
				_selected_entity = null
			GameEngine.context.select_tile(tile)
		
		update_action_info(_selected_entity)
		
	func process_keyboard_input(event, input_manager):
		if input_manager.is_movement_event(event):
			input_manager.process_movement_event(event)

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
		
		if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
			var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
		
	func process_keyboard_input(event, input_manager):
		if input_manager.is_movement_event(event):
			input_manager.process_movement_event(event)
		
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
		
		#If the weapon is ranged, we should change to "range mode"
		var pentity = GameEngine.context.get_player_entity()
		#var is_ranged = Utils.weapon_equipped_is_ranged(pentity)
		
		
		var equipped_entity = Utils.get_entity_weilded_weapon(pentity)
		var wcomponent = Utils.get_component(equipped_entity, 'weapon')
		var wrange = 1
		var wtype = 1
		if (wcomponent):
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
			if _selected_entity:
				if wtype == 1: #Ranged firearm
					action = ActionFactory.create_aim_action(pentity, _selected_entity)
				elif wtype == 2:
					action = ActionFactory.create_magic_aim_action(pentity, _selected_entity)
				else:
					assert(false)
					
				action.consumes_turn = false
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

class CrouchInputState extends InputState:
	func on_enter():
		#Unselects any entity when we switch to default
		SignalManager.emit_signal('unselect_entity')
		var pentity = GameEngine.context.get_player_entity()
		_action = ActionFactory.create_crouch_action(pentity)
		SignalManager.emit_signal('send_action', _action)
		
	func on_exit():
		var pentity = GameEngine.context.get_player_entity()
		_action = ActionFactory.create_stand_action(pentity)
		SignalManager.emit_signal('send_action', _action)
		
	func process_mouse_input(event):
		.process_mouse_input(event)
		
		if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
			var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
			var pentity = GameEngine.context.get_player_entity()
			var path = GameEngine.context.compute_player_path(tile)
			_action = ActionFactory.create_sneak_action(pentity, path)
			_action.num_states = len(path)
			SignalManager.emit_signal('send_action', _action)
		
	func process_keyboard_input(event, input_manager):
		if input_manager.is_movement_event(event):
			#GameEngine.get_world_map().overlay_layer._fsm.emit("overlay_cancel_mode")
			input_manager.process_movement_event(event)

class UseInputState extends InputState:
	func process_mouse_input(event):
		.process_mouse_input(event)
		if _selected_entity:
			var pentity = GameEngine.context.get_player_entity()
			_action = ActionFactory.create_use_action(pentity, _selected_entity)
			if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT):
				var tile = GameEngine.context.world.world_map.worldTileFromScreenPos(event.position)
				SignalManager.emit_signal('send_action', _action)
				update_action_info(_selected_entity)
