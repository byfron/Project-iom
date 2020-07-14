extends Node
const ActionTypes = preload('res://game/actions/ActionTypes.gd').ActionType
#var Actions = load("res://game/core/Actions.gd").new()

func create_fly_action(entity, curve, tile_path):
	var fly_action = load("res://game/actions/native_actions/Fly.tscn").instance()
	fly_action.init(entity)
	fly_action.curve = curve
	fly_action.tile_path = tile_path
	
	#make as many states as tiles in the path
	fly_action.num_states = 1#len(tile_path)
	
	#TODO: We should compute the duration acoording to distance and speed!!!!
	#fly_action.action_duration = len(tile_path) * 0.05
	
	return fly_action
	
func create_explode_action(entity):
	var explode_action = load("res://game/actions/native_actions/Explode.tscn").instance()
	explode_action.init(entity)
	return explode_action

func create_throw_item_action(entity, thrown_entity):
	var throw_action = load("res://game/actions/user_actions/Throw.tscn").instance()
	var action_info = EntityPool.action_map[ActionTypes.THROW_ITEM]
	throw_action.init_action(action_info, entity)
	throw_action.thrown_entity = thrown_entity
	throw_action.signal_on_touch = "overlay_aim_mode"
	return throw_action

func create_death_action(entity):
	var death_action = load("res://game/actions/native_actions/Death.tscn").instance()
	death_action.init(entity)
	return death_action

func create_surprised_action(entity, from_tile):
	var surprised_action = load("res://game/actions/native_actions/Surprised.tscn").instance()
	surprised_action.init(entity)
	surprised_action.from_tile = from_tile
	return surprised_action

func create_walk_action(entity, path = null, responsive=false):
	var action_info = EntityPool.action_map[ActionTypes.WALK]
	var run_action = load("res://game/actions/user_actions/Run.tscn").instance()
	run_action.init_action(action_info, entity)
	run_action.path = path
	run_action.responsive = responsive
	return run_action

func create_takehit_action(entity, from_tile, damage):
	var take_hit = load("res://game/actions/user_actions/TakeHit.tscn").instance()
	take_hit.init(entity)
	take_hit.damage = damage
	take_hit.from_tile = from_tile
	return take_hit
	
func create_aim_action(attacking_entity, attacked_entity):
	var aim_action = load("res://game/actions/user_actions/Aim.tscn").instance()
	aim_action.init(attacking_entity)
	aim_action.aimed_entity = attacked_entity
	return aim_action
	
func create_ranged_attack_action(attacking_entity, to_tile):
	var fire_action = load("res://game/actions/user_actions/FirePistol.tscn").instance()
	fire_action.init(attacking_entity)
	
	var weapon_entity = Utils.get_entity_weilded_weapon(attacking_entity)
	fire_action.weapon_entity = weapon_entity
	var wtype = weapon_entity.components['weapon'].get_weapon_type()
	fire_action.attacked_tile = to_tile
	fire_action.success_rate = Utils.get_modified_skill(attacking_entity, Utils.get_skill_of_weapon(wtype))
	fire_action.roll_text = 'Success rate: ' + str(fire_action.success_rate) + '%'
	fire_action.valid_range = weapon_entity.components['weapon'].get_range()
	return fire_action

func create_melee_attack_action(pentity, to_tile = null):
	var action_info = EntityPool.action_map[ActionTypes.ATTACK]
	
	#TODO: this will depend on wielded weapon!
	
	var punch_action = load("res://game/actions/user_actions/CrossPunch.tscn").instance()
	punch_action.init_action(action_info, pentity)
	
	if to_tile:
		punch_action.attacked_tile = to_tile
	
	return punch_action
	
func create_use_action(pentity, used_entity):
	
	#if entity has door comp
	if 'door' in used_entity.components:
		return create_open_close_action(pentity, used_entity)
		
	assert(false)
	
func create_open_close_action(pentity, to_entity):
	var action = load("res://game/actions/user_actions/OpenClose.tscn").instance()
	action.init(pentity)
	action.used_entity = to_entity
	return action

func create_drop_action(pentity, item_entity):
	var action = load("res://game/actions/user_actions/DropItem.tscn").instance()
	action.init(pentity)
	action.item_entity = item_entity
	return action

func create_crouch_action(pentity):
	var action = load("res://game/actions/user_actions/Crouch.tscn").instance()
	action.init(pentity)
	return action

func create_stand_action(pentity):
	var action = load("res://game/actions/user_actions/Stand.tscn").instance()
	action.init(pentity)
	return action

func create_sneak_action(pentity, path = null, responsive=false):
	var action = load("res://game/actions/user_actions/Sneak.tscn").instance()
	action.init(pentity)
	action.path = path
	action.responsive = responsive
	return action
	
func create_pick_item_action(pentity, container_entity, item_entity):
	var action = load("res://game/actions/user_actions/PickItem.tscn").instance()
	action.init(pentity)
	action.item_entity = item_entity
	action.container_entity = container_entity
	return action
	
func create_equip_action(pentity, item_entity):
	var action = load("res://game/actions/user_actions/Equip.tscn").instance()
	action.init(pentity)
	action.item_entity = item_entity
	return action
	
func create_knockdown_action(entity, tile_path, curve):
	var action = load("res://game/actions/user_actions/Knockdown.tscn").instance()
	action.init(entity)
	action.curve = curve
	action.tile_path = tile_path
	
	#make as many states as tiles in the path
	action.num_states = len(tile_path)
	return action

#The action_id is the identitfier of the action, passed to the buttons
func create_default_action_id(tile):
	var entities = GameEngine.context.get_entities_in_tile(tile)
	if entities:
		#TODO: we'll see how to fix this. 
		var entity = entities[0]
		#TODO: there's lots of logic that should go here. Weapons may not reach... etc...
		#But we can just solve it with dialog/thoughts etc...
		if 'character' in entity.components and 'initiative' in entity.components:
			return ActionTypes.ATTACK
				
		if 'door' in entity.components or 'container' in entity.components:
			return ActionTypes.USE
		
		return null
		
	else:
		return ActionTypes.WALK
		
func create_default_movement_actions(pentity, coords):
	
	var to_entities = GameEngine.context.get_entities_in_tile(coords)
	var actions = []
	var crouching = pentity.components['char_status'].get_crouching()
	
	if to_entities:
		var distance = 0
		#This is solved in order of priority
		for to_entity in to_entities:
			distance = Utils.distance_between_entities(to_entity, pentity)
			if 'character' in to_entity.components and 'initiative' in to_entity.components:
				actions.append(create_melee_attack_action(pentity, Utils.get_entity_location(to_entity)))
				break
				
			if 'door' in to_entity.components and to_entity.components['door'].get_open_closed() == false:
				actions.append(create_open_close_action(pentity, to_entity))
				break
			
			if 'container' in to_entity.components:
				actions.append(create_open_close_action(pentity, to_entity))
				break
		
		return actions
		
	if len(actions) == 0:
		var path = GameEngine.context.compute_player_path(coords)
		#Remove first element which is the same as the players
		path.pop_front()
		if len(path) > 0:
			#TODO: refactor this when we add running
			if crouching:
				actions.append(create_sneak_action(pentity, path, true))
			else:
				actions.append(create_walk_action(pentity, path, true))
		
	return actions
	
func compute_item_actions(item_entity):
	#TODO: temporaly just return drop
	var pentity = GameEngine.context.get_player_entity()
	return [create_drop_action(pentity, item_entity)]