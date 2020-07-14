
var world = null
var action_entities = []
var native_entities = []

var action_queue = ActionQueue.new()
var node_factory = load('res://game/core/NodeFactory.gd').new()
var ActionFactory = load('res://game/core/ActionFactory.gd').new()
var DialogManager = load('res://game/dialogs/DialogManager.gd').new()

var _selected_entity = null
var _is_entity_highlighted = false

var MAX_CONCURRENT_ACTIONS = 5

var _current_actions = []

var player_entity_id = null
var action_map = {}
var _entity2node = {}
var _tile2entity = {}

enum {
	MOVEMENT_MODE,
	AIM_MODE,
	ENTITY_SELECTED_MODE,
	KEYBOARD_SELECT_MODE,
	INFO_MODE
}

#Behaviors
var behavior_map = {}

#Dialogs
var dialog_map = {}

#Useful to map the entities to actions without searching!
class ActionQueue:
	
	class SortByPriority:
		static func sort(a, b):
			if a.priority > b.priority:
				return true
			return false
	
	var action_map = {}
	func has(entity_id):
		return entity_id in self.action_map
		
	#TODO: We should ALSO interrupt the action that may be 
	#in the list of "active" actions.
	func enqueue(entity_id, action):
		
		#A map here and a list in the engine????
		#Shitty solution. send a signal also to the engine
		
		if entity_id in self.action_map:
			#TEST: Leave only one action per actor
			#Interrupt with higher priority new enqueued actions.
			
			var old_action = self.action_map[entity_id][0]
			if action.priority > old_action.priority:
				
				#Send signal action interrupted
				SignalManager.emit_signal('interrupt_action', action, old_action)
				
				self.action_map[entity_id] = [action]
		else:
			self.action_map[entity_id] = [action]

	func get(entity_id):
		if entity_id in self.action_map:
			return self.action_map[entity_id].front()
		else:
			return null

	func pop(entity_id):
		if entity_id in self.action_map:
			var action = self.action_map[entity_id].pop_front()
			if len(self.action_map[entity_id]) == 0:
				#Remove entry if queue is empty
				self.action_map.erase(entity_id)
		else:
			return null
			
	func empty():
		return self.action_map.empty()

#TODO: organize context so that API is sane and easy to remember/use

func register_signals():
	SignalManager.connect("send_action", self, "action_received")

func action_received(action):
	
	#enque multiple actions and sort by priority so that we can 
	#interrupt things?
	
	#Do not enque action if the entity has actions pending
	#if action_queue.get(action.entity.id):
	#	return
	
	if action:
		action.start(action, self)
		action_queue.enqueue(action.entity.id, action)
	
func get_selected_entity():
	return _selected_entity
	
func is_walkable(tile):
	return not Vector2(tile.x, tile.y) in world.wlk_obstacles
	
func get_current_tile():
	return get_player_node().coords
	
func tile_to_chunk(tile):
	#TODO: size of chunk hardcoded!
	return Vector3(int(tile.x/35), int(tile.y/25), tile.z)
	
func get_current_chunk():
	var player_tile = get_current_tile()
	return tile_to_chunk(player_tile)
	
func get_entity_node(entity):
	return _entity2node[entity.id]
	
func get_player_node():
	return _entity2node[player_entity_id]
	
func get_player_entity():
	return EntityPool.get(player_entity_id)
	
func get_entities_with_component(comp_id):
	return EntityPool.filter(comp_id)

func enqeue_action(action):
		self.action_queue.append(action)

func create_torch(torch):
	var node = node_factory.createTorchNode(self, torch)
	world.set_object_node(node)
	
func create_campfire(campfire):
	var node = node_factory.createCampFireNode(self, campfire)
	world.set_object_node(node)

func create_light(light):
	var node = node_factory.createLightNode(self, light)
	world.set_object_node(node)

func create_sound_node(sound_entity):
	var node = node_factory.createSoundNode(self, sound_entity)
	_entity2node[sound_entity.id] = node
	#TODO have its own node layer for this?
	world.set_object_node(node)

func select_tile_from_screen_pos(spos):
	var tile = world.world_map.worldTileFromScreenPos(spos)
	select_tile(tile)
	
func send_current_actions():
	for action in _current_actions:
		SignalManager.emit_signal('send_action', action)
		
	_current_actions = []
	
func select_entity(entity):
	SignalManager.emit_signal('highlight_entity', entity)
	var tile = Utils.get_entity_location(entity)
	
func unselect_entity(entity):
	SignalManager.emit_signal('unhighlight_entity', entity)
	SignalManager.emit_signal('unhighlight_all_buttons')
	
func unselect_tile():
	SignalManager.emit_signal('unhighlight_tile')
	
func select_tile(tile):
	var ActionTypes = load('res://game/actions/ActionTypes.gd')
	SignalManager.emit_signal('highlight_tile', tile)
	SignalManager.emit_signal('highlight_action_button', ActionTypes.ActionType.WALK)
	
func create_object(entity):
	var node = node_factory.createObjectNode(entity)
	world.set_object_node(node)
	_entity2node[node.entity_id] = node

func create_ground_item(entity, tile):
	var node = node_factory.createGroundItemNode(entity, tile)
	world.set_object_node(node)
	_entity2node[entity.id] = node
	add_entity_to_tile(entity, tile)
	
func create_item(entity, tile):
	var node = node_factory.createItemNodeInLocation(entity, tile)
	world.set_object_node(node)
	_entity2node[node.entity_id] = node
	add_entity_to_tile(entity, tile)

func get_char_entity_in_tile(tile):
	var entities = get_entities_in_tile(tile)
	for ent in entities:
		var char_stats = Utils.get_component(ent, 'char_stats')
		if char_stats:
			return ent

func get_item_nodes_in_tile(tile):
	var nodes = []
	var entities = get_entities_in_tile(tile)
	for ent in entities:
		if 'item' in ent.components:
			nodes.append(_entity2node[ent.id])
			
	return nodes
		

func create_character(entity):
	var node = node_factory.createActorNode(entity)
	world.set_actor_node(node)
	_entity2node[node.entity_id] = node
	
	#Create behaviors
	if 'behavior' in entity.components:
		var comp = entity.components['behavior']
		var btree_resource = 'res://game/behaviors/trees/' + comp.get_script() + '.tscn'
		var bree = load(btree_resource)
		behavior_map[entity.id] = bree.instance()
		behavior_map[entity.id].init_behavior(self)
		
	#Create dialogs
	if 'dialog' in entity.components:
		var comp = entity.components['dialog']
		var dialog = DialogManager.create_character_dialog(comp.get_dialog_states())
		dialog_map[entity.id] = dialog
		node.add_child(dialog)
		
func create_player_character(entity):
	player_entity_id = entity.id
	var node = node_factory.createPlayerActorNode(entity)
	_entity2node[node.entity_id] = node
	world.set_player_node(node)
	#add node to juicyCamera
	world.camera.player_actor = node
	
	#enable node light
	node.enable_light()
	
func get_entities_in_2Dtile_plevel(tile):
	var xtile = Vector3(tile.x, tile.y, get_current_tile().z)
	if xtile in _tile2entity:
		return _tile2entity[xtile]
	return []
	
func get_entities_in_tile(tile):
	if tile in _tile2entity:
		return _tile2entity[tile]
	return []
	
func get_path_manager():
	return world.world_map.path_manager
	
func compute_player_path(dst):
	var src = get_player_node().coords
	var path = world.world_map.path_manager.compute_path(src, dst)
	#TODO: this is very ugly
	for i in range(len(path)):
		var t = path[i]
		path[i] = Vector3(t.x, t.y, src.z)
	return path
	
func delete_entity_node(entity):
	if entity.id in _entity2node:
		var node = _entity2node[entity.id]
		world.remove_actor_node(node)
	
func remove_entity_from_tile(entity, tile):
	var entities_in_tile = _tile2entity[tile]
	if len(entities_in_tile) == 1:
		_tile2entity.erase(tile)
	else:
		var entities_left = []
		for entity_in_tile in _tile2entity[tile]:
			if entity_in_tile.id != entity.id:
				entities_left.append(entity_in_tile)
		_tile2entity[tile] = entities_left

func add_entity_to_tile(entity, tile):
	if tile in _tile2entity:
		_tile2entity[tile].append(entity)
	else:
		_tile2entity[tile] = [entity]

func move_player_to_tile(entity, tile):
	
	var node = _entity2node[entity.id]
	
	#Hide any item-UI from the current tile (if any)
	var items = get_item_nodes_in_tile(node.coords)
	for item in items:
		item.hide_buttons()
			
	var current_chunk = get_current_chunk()
	remove_entity_from_tile(entity, node.coords)
	add_entity_to_tile(entity, tile)
	
	var screen_pos = Utils.getScreenCoordsTileCenter(tile)
	node.moveTo(tile, screen_pos)
	
	#if level has changed, we clear the tilemaps
	if get_current_chunk().z != current_chunk.z:
		#clear and re-set collision map and FOV
		world.load_zlevel(get_current_chunk().z)
		
	elif get_current_chunk() != current_chunk:
		world.update_map_chunks()
		
	#check if we have a item in the current tile, to show the UI
	items = get_item_nodes_in_tile(node.coords)
	for item in items:
		item.show_buttons()
	
	world.moveCamera(screen_pos)
	
func move_entity_to_tile(entity, tile, use_tweeen=true):
	if entity.id == player_entity_id:
		move_player_to_tile(entity, tile)
		return
		
	var node = _entity2node[entity.id]
	remove_entity_from_tile(entity, node.coords)
	add_entity_to_tile(entity, tile)
	
	var screen_pos = Utils.getScreenCoordsTileCenter(tile)
	node.moveTo(tile, screen_pos, use_tweeen)
