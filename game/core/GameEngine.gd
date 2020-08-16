extends Node

onready var UserContext = preload('res://game/core/UserContext.gd')
onready var BehaviorSystem = preload('res://game/core/systems/BehaviorSystem.gd')
onready var FuzzyPatternMatcher = preload('res://game/dialogs/FuzzyPatternMatcher.gd')

var state_manager = preload('res://game/core/states/StateManager.gd').new()

var debug_mode = false
var systems = []
var context = null
var turn_has_finished = true
var turn_system = null
var _is_running = false
var _timer = null
var _active_actions = []
var _waiting_for_player = true
var _behavior_system = null
var MAX_TURN_TIME = 0.15
var DEFAULT_MEMORY_CLEAN_TURNS = 50
var DEFAULT_ENTMEM_CLEAN_TURNS = 200

var current_turn_time = 0
var action_list = []
var waiting_time = 0
var cinematic_state = false
var paused = false
var _fuzzy_dialog_matcher = null

enum TILEMAPSTACK {
	GROUND = 1,
	OVERGROUND = 2,
	DECORATION = 3,
	OBJECT = 4,
	META = 5
}

func set_debug_mode(mode):
	debug_mode = mode
	if mode:
		context.world.debug_panel.show()
	else:
		context.world.debug_panel.hide()

func _ready():
	
	_behavior_system = BehaviorSystem.new()
	_fuzzy_dialog_matcher = FuzzyPatternMatcher.new()
	systems.append(BehaviorSystem.new())
	context = create_context()
	state_manager.init()
	
	#Create dialog database from cvs
	#_fuzzy_dialog_matcher.create_database('res://game_assets/dialogs/Eric.csv')
	_fuzzy_dialog_matcher.create_database('res://game_assets/dialogs/Carla.csv')
	SignalManager.connect("query_dialog_system", _fuzzy_dialog_matcher, "process_query")
	
	#Load metadata of ResourceManager
	ResourceManager.load_fx_animation_metadata("res://resources/metadata/fx_animations.json")
	ResourceManager.load_char_animation_metadata("res://resources/metadata/char_animations.json")
	ResourceManager.load_char_object_animation_metadata("res://resources/metadata/char_object_animations.json")
	ResourceManager.load_item_animation_metadata("res://resources/metadata/item_animations.json")
	ResourceManager.load_item_icon_metadata("res://resources/metadata/item_icons.json")
	ResourceManager.load_object_sprite_metadata()
	ResourceManager.load_item_sprite_metadata()
	
	#We need to be able to "hot"-insert actions in the list of actives
	#in case there's an interruption
	SignalManager.connect("interrupt_action", self, "interrupt_action")
	
	SignalManager.connect("item_button_pressed", state_manager, "process_item")
	SignalManager.connect("action_button_pressed", state_manager, "process_action")
	SignalManager.connect("status_button_pressed", state_manager, "process_status")
	SignalManager.connect("status_button_released", state_manager, "process_status")
	SignalManager.connect("status_event", state_manager, "process_status")
	SignalManager.connect("activate_sin", state_manager, "process_activate_sin")
	SignalManager.connect("deactivate_sin", state_manager, "process_deactivate_sin")
	
func get_current_state():
	return state_manager.get_current_state()
	
func interrupt_action(entity_id, new_action, old_action):
	
	#TODO! Warning! The action_list is deprecated so the interruption
	#code may be broken. Make sure it's still needed
	
	var action_list = context.action_queue.action_map[entity_id]
	var idx = action_list.find(old_action)
	if idx >= 0:
		action_list.remove(idx)
		
	action_list.append(new_action)
	
	#re-sort
	#action_list.sort_custom(PrioritySorter, "sort_descending")
	
class PrioritySorter:
	static func sort_descending(a, b):
		if a.priority > b.priority:
			return true
		return false

func clear_up_finished_actions():
	
	var actions_to_pop = []
	
	for entity_id in context.action_queue.action_map:
		var action = context.action_queue.get(entity_id)
		if ((action.responsive and action.current_state == action.num_states-1) or 
			(action.is_finished() and not action.infinite)):
			actions_to_pop.append(action)
			
	for action in actions_to_pop:
		action.on_finish(context)
		context.action_queue.pop(action.entity.id)
		SignalManager.emit_signal("pop_action", action)
	
func get_overlay_layer():
	return context.world.world_map.overlay_layer
	
func run_next_turn():
	
	#TODO:!!! WTF is this doing here?
	#get_overlay_layer().hide_motion_grid()
	
	#active entities without player
	var active_entities = get_active_entities(false)
	
	#TODO: what about the objects with no initiative? 
	#They may need to (for instance) take damage with actions
	
	#initialize_actions_from_queue()
	for entity in active_entities:
		
		#Check that entity has initiative. It may have died this turn
		#TODO: this wont work now with object entities also being processed
		#if not entity.components.has('initiative'):
		#	continue
		
		var action = context.action_queue.get(entity.id)
		if action == null and entity.components.has('initiative'):
			_behavior_system.update(context, entity)
			print('Updates behavior tree for ', entity.name)
			action = context.action_queue.get(entity.id)
		else:
			print(entity.name, ' has a unfinished action')

		if action:
			action.change_state(context)
		else:
			print('But action is null')
			
	current_turn_time = 0
	context.clear_dead_entities()

	#decreases one turn to the memory of all active actors
	for eid in get_active_entity_ids_with_initiative():
		context.update_actor_memory(eid)
	
func is_time_to_run_turn():
	if current_turn_time >= MAX_TURN_TIME:
		return true
		
	return false
	
func notify_time_to_new_actions(time_value):
	var active_entities = get_active_entities(false)
	for entity in active_entities:
		var action = context.action_queue.get(entity.id)
		if action:
			action.current_state_time = time_value
	
func _process(delta):
	
	if paused:
		return
	
	for entity_id in context.action_queue.action_map:
		var action = context.action_queue.get(entity_id)
		#for action in action_list:
		action.process(context, current_turn_time)
		
	var player_entity = context.get_player_entity()
	var player_action = context.action_queue.get(player_entity.id)
	
	if context.player_is_dead:
		if is_time_to_run_turn():
			run_next_turn()
			
	elif player_action != null:
		
#		if player_is_frozen: #ignore action and pop it
#			context.action_queue.pop(player_action.entity.id)
#		else:
#
		# Jump ahead of time if the player action is responsive
		if player_action.responsive and not cinematic_state:
			current_turn_time = MAX_TURN_TIME
			
		#Some actions may not consume any turn, so they just happen, and 
		#player plays again
		if not player_action.consumes_turn():
			player_action.change_state(context)
		else:
			# Execute player action first
			if is_time_to_run_turn():
				player_action.change_state(context)
				run_next_turn()
		
		#notify_time_to_new_actions(current_turn_time)
		
	#TIME STOPS after max_turn_time
	if current_turn_time < MAX_TURN_TIME:
		current_turn_time += delta
		
	clear_up_finished_actions()
		
		
func get_active_entities(return_player_entity = true):
	var entity_ids = get_active_entity_ids_with_initiative()
	
	#add all other entities present in the action_map
	#with no initiative
	for entity_id in context.action_queue.action_map:
		if entity_ids.find(entity_id) == -1:
			entity_ids.append(entity_id)
		
	if not return_player_entity:
		entity_ids.erase(context.get_player_entity().id)
		
	var entities = []
	for eid in entity_ids:
		entities.append(EntityPool.get(eid))
		
	return entities
	
func get_active_entity_ids_with_initiative():
	var entities = context.get_entities_with_component('initiative')
	
	#Consider only entities in this Z level
	#TODO: now entities can't move across levels
	var z_entities = []
	for ent in entities:
		var location = Utils.get_entity_location(ent)
		if location.z == context.get_current_chunk().z:
			z_entities.append(ent.id)
			
	return z_entities

func create_context():
	return UserContext.new()

func get_world_map():
	return context.world.world_map

func initialize_world(world_scene):
	context.world = world_scene
	context.register_signals()

	#create main character
	var main_char_entities = EntityPool.filter('main_character')
	#assert(len(main_char_entities) == 2)
	
	for main_char in main_char_entities:
		var is_companion = main_char.components['main_character'].get_is_companion()
		if is_companion:
			context.create_companion_character(main_char)
		else:
			context.create_player_character(main_char)

	var player_z_level = context.get_player_entity().components['location'].get_coord().get_z()
	
	
	#TODO: we should have the entities already in some kind of octreee so that we only initialize a local
	#subset of the world
	#initialize map with chunk components
	var chunk_entities = EntityPool.filter('chunk')
	context.world.initialize_from_chunk_components(chunk_entities, player_z_level)
	
	create_entity_nodes(player_z_level)
	
func create_entity_nodes(player_z_level):
		#add all location entities to the map (that are at the same level as the player)
	#TODO: maybe eventually also add only the ones around the player
	var location_entities = EntityPool.filter('location')
	for entity in location_entities:
		#entities with no name are not added in the context map
		if entity.name != '':
			var location_comp = entity.components['location'].get_coord()
			if location_comp.get_z() != player_z_level:
				continue
			if entity.name == 'Barrel':
				pass
				
			context.add_entity_to_tile(entity, Vector3(location_comp.get_x(), location_comp.get_y(), location_comp.get_z()))
				
		var tile = Utils.get_entity_location(entity)
				
		if 'character' in entity.components:
			context.create_character(entity)
		else:
			if 'main_character' in entity.components:
				continue
				
			#TODO: refactor somewhere
			if 'volume' in entity.components:
				
				#add obstacles across the whole volume
				var htiles = entity.components['volume'].get_h_tiles()
				var wtiles = entity.components['volume'].get_w_tiles()
				
				#add walk obstacle				
				for h in range(htiles):
					for w in range(wtiles):
						context.world.wlk_obstacles[Vector2(tile.x+w, tile.y+h)] = 1
				
				#If the volume hight is more than one, we also add a fov obstacle
				var volume_height = entity.components['volume'].get_height()
				if  volume_height > 1:
					for h in range(htiles):
						for w in range(wtiles):
							context.world.fov_obstacles[Vector2(tile.x+w, tile.y+h)] = volume_height
					
			context.create_object(entity, tile)
	
	
	
	#create light entities
#	for light in EntityPool.filter('light'):
#		var location_comp = light.components['location'].get_coord()
#		if location_comp.get_z() != player_z_level:
#			continue
#		context.create_light(light)
		
	#TODO: This should dynamically change the graphics of the fire
	#Some fire may be just lava tiles(no graphics, no smoke), while other can be a campfire
	for campfire in EntityPool.filter('fire'):
		var location_comp = campfire.components['location'].get_coord()
		if location_comp.get_z() != player_z_level:
			continue
			
		if campfire.name == 'Torch':
			context.create_torch(campfire)
		else:
			context.create_campfire(campfire)
		
	

	
