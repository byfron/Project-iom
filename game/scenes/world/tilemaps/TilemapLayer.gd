extends Node2D
tool

onready var tilemap = $Tilemap

#Keep tilematrix array as a dictionary
var map_chunks = {}
var map_data = {}
var tile_metadata_map = {}

export(TileSet) var tileset setget update_tileset
export(String) var autotiler_cfg setget set_autotiler_cfg
export(bool) var is_objectmap

func _ready():
	tilemap.tile_set = tileset

func set_autotiler_cfg(cfg):
	autotiler_cfg = cfg
	
func update_tileset(tset):
	tileset = tset
	if Engine.editor_hint:
		tilemap.tile_set = tileset

func add_empty_chunk(chunk_coord, rect):
	var autotiler = Autotilemap.new()

	var br = rect.get_bottom_right()
	var tl = rect.get_top_left()
	var sizex = br.get_x() - tl.get_x()
	var sizey = br.get_y() - tl.get_y()

	#TODO: avoid this loop (do it in the module)
	autotiler.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()), Vector2(br.get_x(), br.get_y()), autotiler_cfg)
	
#	var idx = 0
#	for row in range(sizey):
#		for col in range(sizex):
#			var code = data[idx]
#			autotiler.set_value(col, row, code)
#			idx += 1
	
	map_chunks[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = autotiler
	
func add_chunk(chunk_coord, rect, data):
	
	var autotiler = Autotilemap.new()

	var br = rect.get_bottom_right()
	var tl = rect.get_top_left()
	var sizex = br.get_x() - tl.get_x()
	var sizey = br.get_y() - tl.get_y()

	#TODO: avoid this loop (do it in the module)
	autotiler.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()), Vector2(br.get_x(), br.get_y()), autotiler_cfg)
	var idx = 0

	for row in range(sizey):
		for col in range(sizex):
			var code = data[idx]
			autotiler.set_value(col, row, code)
			idx += 1
	
	print('Adding chunk ' + str(chunk_coord.get_x()) + "," + str(chunk_coord.get_y()) + "," + str(chunk_coord.get_z()))
	map_chunks[Vector3(chunk_coord.get_x(), chunk_coord.get_y(), chunk_coord.get_z())] = autotiler
	
func merge_maps(chunks):
	var top_left = null
	var bottom_right = null
	var width = 0
	var height = 0
	
	if chunks.empty():
		return null

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
	full_map.init(Vector2(0,0), top_left, bottom_right, autotiler_cfg)
			
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
	tilemap.set('tile_data', [])

func refresh():
	#We should ONLY copy back the 3x3 blocks
	#var full_array = tilemap.get('tile_data')
	#merge all wallmaps before applying autotilling
	
	#Given the current chunk, keep only the ones that matter
	
	var chunks = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks)
	
	var full_wallmap = merge_maps(chunks)
	if full_wallmap:
		full_wallmap.apply(tilemap)
	
func update_tilemap(pos, tid):
	var chunk_coord = GameEngine.context.tile_to_chunk(pos)
	if chunk_coord in map_chunks:
		map_chunks[chunk_coord].set_value_relative_to_tl(pos.x, pos.y, tid)
	
	#TODO: if too slow. Keep a map of tiles that changes so that we 
	#only go through those (and neighbors)
	var chunks = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks)
	var full_wallmap = merge_maps(chunks)
	if full_wallmap:
		full_wallmap.apply(tilemap)

func select_object(tile):
	var cell = tilemap.get_cell(tile.x, tile.y)
	$ObjectSelectLayer.set_cell(tile.x, tile.y, cell)

func unselect_object(tile):
	$ObjectSelectLayer.set_cell(tile.x, tile.y, 0)

func clear():
	map_data = {}
	tilemap.clear()
