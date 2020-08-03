extends Node2D
#tool

onready var tilemap_0 = $Tilemap_0
onready var tilemap_1 = $Tilemap_1
#onready var shadows = $Shadows
#Keep tilematrix array as a dictionary
var map_chunks_0 = {}
var map_chunks_1 = {}

var map_data = {}
var tile_metadata_map = {}

export(TileSet) var tileset setget update_tileset
export(String) var autotiler_cfg_0 setget set_autotiler_cfg_0
export(String) var autotiler_cfg_1 setget set_autotiler_cfg_1
export(bool) var is_objectmap

func _ready():
	pass
	
func init():
	tilemap_0.tile_set = tileset
	tilemap_1.tile_set = tileset
	#shadows.tile_set = tileset

func set_autotiler_cfg_0(cfg):
	autotiler_cfg_0 = cfg
	
func set_autotiler_cfg_1(cfg):
	autotiler_cfg_1 = cfg	
	
func update_tileset(tset):
	tileset = tset
	if Engine.editor_hint:
		tilemap_0.tile_set = tileset
		tilemap_1.tile_set = tileset
		#shadows.tile_set = tileset
	
func add_chunk(chunk_coord, rect, data):
	#Compute two autotilers for top and bottom levels
	var autotiler_0 = Autotilemap.new()
	var autotiler_1 = Autotilemap.new()

	var br = rect.get_bottom_right()
	var tl = rect.get_top_left()
	var sizex = br.get_x() - tl.get_x()
	var sizey = br.get_y() - tl.get_y()
	
	#TODO: avoid this loop (do it in the module)
	autotiler_0.init(Vector2(tl.get_x(), tl.get_y()), Vector2(br.get_x(), br.get_y()), autotiler_cfg_0)
	
	#set data in a higher row for the top level map
	autotiler_1.init(Vector2(tl.get_x(), tl.get_y()-1), Vector2(br.get_x(), br.get_y()-1), autotiler_cfg_1)
	
	var idx = 0
	for row in range(sizey):
		for col in range(sizex):
			var code = data[idx]
			autotiler_0.set_value(col, row, code)
			
			autotiler_1.set_value(col, row, code)
			
			idx += 1
			
	print('Adding chunk ' + str(chunk_coord.get_x()) + "," + str(chunk_coord.get_y()) + "," + str(chunk_coord.get_z()))
	map_chunks_0[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = autotiler_0
	map_chunks_1[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = autotiler_1
	
func merge_maps(chunks, autotiler_cfg):
	var top_left = null
	var bottom_right = null
	var width = 0
	var height = 0
	
	if chunks.empty():
		return null	
		
	var num_map_chunks = len(chunks)

	for autotiler in chunks:
		if not autotiler:
			continue

		if top_left != null:
			top_left = Vector2(min(autotiler.get_top_left().x, top_left.x), 
							   min(autotiler.get_top_left().y, top_left.y))
		else:
			top_left = autotiler.get_top_left()
			
		if bottom_right != null:
			bottom_right = Vector2(max(autotiler.get_bottom_right().x, bottom_right.x), 
								   max(autotiler.get_bottom_right().y, bottom_right.y))
		else:
			bottom_right = autotiler.get_bottom_right()
			
	width = bottom_right.x - top_left.x
	height = bottom_right.y - top_left.y
		
	var full_map = Autotilemap.new()
	full_map.init(top_left, bottom_right, autotiler_cfg)
	
	for autotiler in chunks:
		if autotiler:
			full_map.set_submap(autotiler.get_top_left(), autotiler.get_width(), autotiler.get_height(), autotiler.get_data())
			
	return full_map

func get_3x3_autotilers(player_chunk, tilemap_matrix):
	var matrix3x3 = []
	var offsets = [[-1, -1], [0, -1], [1, -1], 
				   [-1,  0], [0,  0], [1,  0],
				   [-1,  1], [0,  1], [1,  1]]
	
	for offset in offsets:
		var coord = Vector3(player_chunk.x + offset[0], player_chunk.y + offset[1], player_chunk.z)
		
		if coord in tilemap_matrix:
			matrix3x3.append(tilemap_matrix[coord])
		else:
			print('Error: the map should not have this coord!' + str(coord))
		#	assert(false)
	return matrix3x3

func clear_tilemap():
	tilemap_0.set('tile_data', [])
	tilemap_1.set('tile_data', [])
	#shadows.set('tile_data', [])

func refresh():
	var chunks_0 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_0)
	var chunks_1 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_1)
	
	var full_wallmap_0 = merge_maps(chunks_0, autotiler_cfg_0)
	var full_wallmap_1 = merge_maps(chunks_1, autotiler_cfg_1)
	if full_wallmap_0:
		full_wallmap_0.apply(tilemap_0)
		#full_wallmap_0.apply(shadows)
		
	if full_wallmap_1:
		full_wallmap_1.apply(tilemap_1)
	
func update_tilemap(pos, tid):
	var chunk_coord = GameEngine.context.tile_to_chunk(pos)
	if chunk_coord in map_chunks_0:
		map_chunks_0[chunk_coord].set_value_relative_to_tl(pos.x, pos.y, tid)
		
	#TODO: does this need to be also SHIFTED??? Are we EVER updating the roof?
	if chunk_coord in map_chunks_1:
		map_chunks_1[chunk_coord].set_value_relative_to_tl(pos.x, pos.y, tid)
	
	#TODO: if too slow. Keep a map of tiles that changes so that we 
	#only go through those (and neighbors)
	var chunks_0 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_0)
	var full_wallmap_0 = merge_maps(chunks_0, autotiler_cfg_0)
	if full_wallmap_0:
		full_wallmap_0.apply(tilemap_0)
		#full_wallmap_0.apply(shadows)
		
	var chunks_1 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_1)
	var full_wallmap_1 = merge_maps(chunks_1, autotiler_cfg_1)
	if full_wallmap_1:
		full_wallmap_1.apply(tilemap_1)

func select_object(tile):
	var cell = tilemap_0.get_cell(tile.x, tile.y)
	$ObjectSelectLayer.set_cell(tile.x, tile.y, cell)

func unselect_object(tile):
	$ObjectSelectLayer.set_cell(tile.x, tile.y, 0)

func clear():
	map_data = {}
	tilemap_0.clear()
	tilemap_1.clear()
	#shadows.clear()
