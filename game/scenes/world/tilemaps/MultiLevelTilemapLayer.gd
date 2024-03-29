extends Node2D
#tool

onready var tilemap_a = $TilemapA
onready var tilemap_b = $TilemapB
onready var tilemap_top = $tilemap_top
onready var shadows = $Shadows

#Keep tilematrix array as a dictionary
var map_chunks_01 = {}
var map_chunks_02 = {}
var map_chunks_1 = {}

var map_data = {}
var tile_metadata_map = {}

export(TileSet) var tileset setget update_tileset
export(String) var autotiler_cfg_bottom setget set_autotiler_cfg_bottom
export(String) var autotiler_cfg_top setget set_autotiler_cfg_top
export(bool) var is_objectmap

func _ready():
	pass
	
func init():
	tilemap_a.tile_set = tileset
	tilemap_b.tile_set = tileset
	tilemap_top.tile_set = tileset
	shadows.tile_set = tileset

func set_autotiler_cfg_bottom(cfg):
	autotiler_cfg_bottom = cfg
	
func set_autotiler_cfg_top(cfg):
	autotiler_cfg_top = cfg	
	
func update_tileset(tset):
	tileset = tset
	if Engine.editor_hint:
		tilemap_a.tile_set = tileset
		tilemap_b.tile_set = tileset
		tilemap_top.tile_set = tileset
		shadows.tile_set = tileset
	
func add_chunk(chunk_coord, rect, data):
	#Compute two autotilers for top and bottom levels
	var autotiler_01 = Autotilemap.new()
	var autotiler_02 = Autotilemap.new()
	var autotiler_1 = Autotilemap.new()

	var br = rect.get_bottom_right()
	var tl = rect.get_top_left()
	var sizex = br.get_x() - tl.get_x()
	var sizey = br.get_y() - tl.get_y()
	
	#TODO: avoid this loop (do it in the module)
	autotiler_01.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()), Vector2(br.get_x(), br.get_y()), autotiler_cfg_bottom)
	autotiler_02.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()-1), Vector2(br.get_x(), br.get_y()-1), autotiler_cfg_bottom)
	
	#set data in a higher row for the top level map
	autotiler_1.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()-2), Vector2(br.get_x(), br.get_y()-2), autotiler_cfg_top)
	
	var idx = 0
	for row in range(sizey):
		for col in range(sizex):
			var code = data[idx]
			autotiler_01.set_value(col, row, code)
			autotiler_02.set_value(col, row, code)
			
			autotiler_1.set_value(col, row, code)
			
			idx += 1
			
	print('Adding chunk ' + str(chunk_coord.get_x()) + "," + str(chunk_coord.get_y()) + "," + str(chunk_coord.get_z()))
	map_chunks_01[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = autotiler_01
	map_chunks_02[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = autotiler_02
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
	tilemap_a.set('tile_data', [])
	tilemap_b.set('tile_data', [])
	tilemap_top.set('tile_data', [])
	shadows.set('tile_data', [])

func refresh():
	var chunks_01 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_01)
	var chunks_02 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_02)
	var chunks_1 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_1)
	
	var full_wallmap_01 = merge_maps(chunks_01, autotiler_cfg_bottom)
	var full_wallmap_02 = merge_maps(chunks_02, autotiler_cfg_bottom)
	var full_wallmap_1 = merge_maps(chunks_1, autotiler_cfg_top)
	if full_wallmap_01:
		full_wallmap_01.apply(tilemap_a)
		full_wallmap_01.apply(shadows)
		
	if full_wallmap_02:
		full_wallmap_02.apply(tilemap_b)
		#full_wallmap_02.apply(shadows)
		
	if full_wallmap_1:
		full_wallmap_1.apply(tilemap_top)
	
func update_tilemap(pos, tid):
	var chunk_coord = GameEngine.context.tile_to_chunk(pos)
	if chunk_coord in map_chunks_01:
		map_chunks_01[chunk_coord].set_value_relative_to_tl(pos.x, pos.y, tid)
		
	if chunk_coord in map_chunks_02:
		map_chunks_02[chunk_coord].set_value_relative_to_tl(pos.x, pos.y, tid)
		
	#TODO: does this need to be also SHIFTED??? Are we EVER updating the roof?
	if chunk_coord in map_chunks_1:
		map_chunks_1[chunk_coord].set_value_relative_to_tl(pos.x, pos.y, tid)
	
	#TODO: if too slow. Keep a map of tiles that changes so that we 
	#only go through those (and neighbors)
	var chunks_01 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_01)
	var full_wallmap_01 = merge_maps(chunks_01, autotiler_cfg_bottom)
	if full_wallmap_01:
		full_wallmap_01.apply(tilemap_a)
		full_wallmap_01.apply(shadows)
		
	var chunks_02 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_02)
	var full_wallmap_02 = merge_maps(chunks_02, autotiler_cfg_bottom)
	if full_wallmap_02:
		full_wallmap_02.apply(tilemap_b)
		
	var chunks_1 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_1)
	var full_wallmap_1 = merge_maps(chunks_1, autotiler_cfg_top)
	if full_wallmap_1:
		full_wallmap_1.apply(tilemap_top)

func select_object(tile):
	var cell = tilemap_a.get_cell(tile.x, tile.y)
	$ObjectSelectLayer.set_cell(tile.x, tile.y, cell)

func unselect_object(tile):
	$ObjectSelectLayer.set_cell(tile.x, tile.y, 0)

func clear():
	map_data = {}
	tilemap_a.clear()
	tilemap_b.clear()
	tilemap_top.clear()
	shadows.clear()
