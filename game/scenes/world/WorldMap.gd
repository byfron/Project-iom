extends Node2D

onready var map_node = $MapNode
onready var actor_layer = $MapNode/ActorLayer
onready var overlay_layer = $MapNode/OverlayLayer
onready var fov_layer = $FOVTilemapLayer 
onready var tilemap_controller = $MapNode/TilemapController
onready var path_manager = $PathManager

onready var water_reflections = $MapNode/WaterReflections

var node_factory = load('res://game/core/NodeFactory.gd').new()
var NodeUtils = load('res://game/utils/NodeUtils.gd').new()

var tile_metadata_map = {}
var map_data = {}
var _world = null
var tl_offset = null
var br_offset = null

signal mouse_on_tile

func display_overlay_action(tile, action):
	overlay_layer.display_action(tile, action)

func draw_aim_line_to_pos(pos):
	var tile = worldTileFromScreenPos(pos)
	var dst_pos = Utils.getScreenCoordsTileCenter(tile)
	var src_pos = GameEngine.context.get_player_node().get_weapon_endpoint()
	overlay_layer.set_aim_line(src_pos, dst_pos)
	
func unhighlight_entity(entity):
	if entity.id in GameEngine.context._entity2node:
		GameEngine.context._entity2node[entity.id].select(false)
	else:
		var htile = Utils.get_entity_location(entity)
		tilemap_controller.actor_layer.unselect_object(htile)

func highlight_entity(entity):
	if entity.id in GameEngine.context._entity2node:
		GameEngine.context._entity2node[entity.id].select(true)
	else:
		var htile = Utils.get_entity_location(entity)
		overlay_layer.select_tile(htile)
		tilemap_controller.actor_layer.select_object(htile)
		
func worldTileFromScreenPos(spos):
	var screen_center = Vector2(get_viewport().size.x, get_viewport().size.y)/2.0
	var camera_pos = _world.camera.get_position()
	var spos_wrt_center = (spos - screen_center) * _world.camera.get_zoom().x
	return Utils.screenToTile(camera_pos + spos_wrt_center)
	
#TODO: refactor here all functions that do not belong here
func load_zlevel(zlevel):
	#free actor nodes except player!
	#unselect first any entity that may be selected
	SignalManager.emit_signal('unselect_entity')
	for actor in actor_layer.get_children():
		if actor.entity_id != GameEngine.context.get_player_entity().id:
			actor_layer.remove_child(actor)
			actor.queue_free()
		
		
	#NodeUtils.delete_children(actor_layer)
	
	tilemap_controller.clear_map_chunks()
	
	#Add object nodes
	GameEngine.create_entity_nodes(zlevel)
	
	#add new actor nodes from the entities in this level/area
	var char_entities = EntityPool.filter('character')
	for char_ent in char_entities:
		if char_ent.components['location'].get_coord().get_z() == zlevel:
			GameEngine.context.create_character(char_ent)
