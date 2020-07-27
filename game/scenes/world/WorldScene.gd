extends Node2D
onready var thread = Thread.new()

#The WorldScene is in charge of the visual elements
#while the UserContext is keeping the data structures to handle game logic. 
#For instance, which entity is in which tile is part of the context, 
#while the SceneNodes or the Tilemaps are part of the WorldScene.

onready var world_map = $WorldMap
onready var camera = $JuicyCamera
onready var input_manager = $JuicyCamera/InputArea
onready var description_panel = $GUILayer/DescriptionPanel
onready var debug_panel =  $GUILayer/DebugPanel
onready var top_bar = $GUILayer/TopBar

onready var container_panel = $GUILayer/ContainerPanel
onready var inventory_panel = $GUILayer/InventoryPanel
onready var item_action_list = $GUILayer/ItemActionList

onready var gui_layer = $GUILayer

#PANELS
onready var info_panel = $GUILayer/InfoPanel
onready var dialog_panel = $GUILayer/DialogPanel


onready var chunk_map = {}
var Utils = load('res://game/utils/Utils.gd').new()

#TODO refactor (send to context or somewhere else)
var fov_obstacles = {}
var wlk_obstacles = {}

func _ready():
	SignalManager.connect("show_inventory", self, "show_inventory")
	SignalManager.connect("hide_inventory", self, "hide_inventory")
	
	SignalManager.connect("highlight_entity", info_panel, "display_entity")
	SignalManager.connect("highlight_entity", world_map, "highlight_entity")
	
	SignalManager.connect("unhighlight_entity", info_panel, "hide_entity")
	SignalManager.connect("unhighlight_entity", world_map, "unhighlight_entity")
	
	#TODO: maybe move to overlay layer
	SignalManager.connect("highlight_tile", world_map.overlay_layer, "select_tile")
	SignalManager.connect("unhighlight_tile", world_map.overlay_layer, "unselect_tile")
	SignalManager.connect("item_selected", self, "show_item_action_list")
	SignalManager.connect("unhighlight_entity", world_map, "unhighlight_entity")
	SignalManager.connect("toggle_debug_mode", debug_panel, "toggle_visibility")
	world_map._world = self
	
	#Place UI panels acoording to screen resolution
	var y_offset = 10
	var x_offset = 10
	dialog_panel.position = Vector2(get_viewport().size.x/2, get_viewport().size.y)
	info_panel.position = Vector2(get_viewport().size.x - x_offset, y_offset)
	info_panel.position = Vector2(get_viewport().size.x - x_offset, y_offset)
	
	camera.make_current()
	
	GameEngine.initialize_world(self)
	
func moveCamera(screen_coords):
	camera.moveTo(screen_coords)
	compute_fov([])

func show_item_action_list(entity):
	var pos = get_viewport().get_mouse_position()
	item_action_list.rect_position = pos
	item_action_list.show_entity_actions(entity)
	item_action_list.show()
	
func show_container():
	container_panel.show()

func hide_container():
	container_panel.hide()

func show_inventory():
	var player_entity = GameEngine.context.get_player_entity()
	inventory_panel.fill_with_inventory(player_entity.components["inventory"])
	inventory_panel.show()

func hide_inventory():
	inventory_panel.hide()
	item_action_list.hide()

func get_info_panel():
	return info_panel

func get_dialog_panel():
	return dialog_panel

func compute_fov(args):
	
	#TODO: magic numbers. FOV radius may change dynamically
	var width = 70
	var height = 34
	var radius = 15
	
	var ssize = Vector2(get_viewport().size.x, get_viewport().size.y)
	var current_tile = GameEngine.context.get_current_tile()
	var light_map = world_map.fov_layer._fov.calculateFOV(fov_obstacles, current_tile.x, current_tile.y, width, height, radius)
	light_map.apply(world_map.fov_layer.tilemap)
	
func set_player_node(actor_node):
	var screen_coords = Utils.getScreenCoords(actor_node.coords)
	world_map.actor_layer.add_child(actor_node)
	moveCamera(screen_coords)
	
func set_actor_node(actor_node):
	world_map.actor_layer.add_child(actor_node)
	
func remove_actor_node(actor_node):
	world_map.actor_layer.remove_child(actor_node)
	
func set_object_node(actor_node):
	world_map.actor_layer.add_child(actor_node)
	
func load_zlevel(zlevel):
	world_map.load_zlevel(zlevel)
	update_collision_map(zlevel)
	update_map_chunks()
	
func update_collision_map(zlevel):
	fov_obstacles = {}
	wlk_obstacles = {}
	var chunk_entities = EntityPool.filter('chunk')
	for entity in chunk_entities:
		var chunk_component = entity.components['chunk']
		var chunk = chunk_component.get_chunk()
		var chunk_coord = chunk.get_coord()
		
		if chunk_coord.get_z() == zlevel:
			initialize_obstacles(chunk)
	
func initialize_obstacles(chunk):
	var chunk_coord = chunk.get_coord()
	var tilemap_array = chunk.get_tilemap()

	for tilemap in tilemap_array:
		var rect = tilemap.get_rect()
		var type = tilemap.get_type()
		if type == 4: #META LAYER
			var br = rect.get_bottom_right()
			var tl = rect.get_top_left()
			var sizex = br.get_x() - tl.get_x()
			var sizey = br.get_y() - tl.get_y()
			var data = tilemap.get_data()
			var idx = 0
			for row in range(sizey):
				for col in range(sizex):
					var code = data[idx]
					idx += 1
					var location = Vector2((tl.get_x() + col), tl.get_y() + row)
					if code & 0x1 == 1:
						fov_obstacles[location] = 1
						
					if (code >> 1) & 0x1:
						wlk_obstacles[location] = 1
						
	world_map.path_manager.set_obstacles(wlk_obstacles)

	
func initialize_from_chunk_components(entities, zlevel):
	#Organize all chunk entities in a map
	for entity in entities:
		var chunk_component = entity.components['chunk']
		var chunk = chunk_component.get_chunk()
		var chunk_coord = chunk.get_coord()
		chunk_map[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = chunk
		if chunk_coord.get_z() == zlevel:
			initialize_obstacles(chunk)
		
	#Initialize tilemap controller with chunks around current player
	var chunk_coords = world_map.tilemap_controller.get_3x3_chunks_around_current()
	world_map.tilemap_controller.add_chunks_from_map(chunk_map, chunk_coords)
	world_map.tilemap_controller.refresh()
	
func clear_map_chunks():
	world_map.tilemap_controller.clear_map_chunks()
	
func update_map_chunks():
	
	#TODO: we may have to do this in parallel
	var chunk_coords = world_map.tilemap_controller.get_3x3_chunks_around_current()
	
	for chunk_coord in chunk_coords:
		if chunk_coord in chunk_map:
			initialize_obstacles(chunk_map[chunk_coord])
	
	world_map.tilemap_controller.add_chunks_from_map(chunk_map, chunk_coords)
	
	world_map.tilemap_controller.refresh()

func update_chunk_database(tile, stack_type, tid):
	#Updates both the tilemap nodes and the chunk protobuf database in memory
	var chunk_coord = GameEngine.context.tile_to_chunk(tile)
	var chunk = chunk_map[chunk_coord]
	var tilemap_array = chunk.get_tilemap()
	
	for tilemap in tilemap_array:
		var rect = tilemap.get_rect()
		var br = rect.get_bottom_right()
		var tl = rect.get_top_left()
		var sizex = br.get_x() - tl.get_x()
		if tilemap.get_type() == stack_type:
			var db_tilemap = tilemap
			var data = tilemap.get_data()
			var offset = Vector2(tile.x - tl.get_x(), tile.y - tl.get_y())
			data[offset.x + offset.y * sizex] = tid
			tilemap.set_data(data)

############################ Experiment###########################################3
#TODO: this should be somewhere else, 
#maybe inside an action that is processed by the weather_system
func start_rain():
	var color = $CanvasModulate.color
	$WeatherTween.interpolate_property($CanvasModulate, "color", color, Color(0.290196, 0.270588, 0.45098), 5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$WeatherTween.start()
	
func _on_WeatherTween_tween_completed(object, key):
	var rain_node = load('res://game/fx/Rain.tscn').instance()
	$JuicyCamera.add_child(rain_node)
	
################################ Experiment###########################################3
