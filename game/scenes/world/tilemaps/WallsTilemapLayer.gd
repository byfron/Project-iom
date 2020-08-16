extends Node2D
#tool

onready var tilemap_bottom = $Tilemap_bottom
onready var tilemap_top = $Tilemap_top

onready var tilemap_bottom_trans = $Tilemap_bottom_transparent
onready var tilemap_top_trans = $Tilemap_top_transparent

onready var actor_node = $Tilemap_bottom

#onready var shadows = $Shadows
#Keep tilematrix array as a dictionary
var map_chunks_0 = {}
var map_chunks_1 = {}
var shrink_wall_cache = {}

var map_data = {}
var tile_metadata_map = {}

export(TileSet) var tileset setget update_tileset
export(String) var autotiler_cfg_bottom setget set_autotiler_cfg_bottom
export(String) var autotiler_cfg_top setget set_autotiler_cfg_top
export(bool) var is_objectmap

func _ready():
	pass
	
func init():
	tilemap_bottom.tile_set = tileset
	tilemap_top.tile_set = tileset
	tilemap_bottom_trans.tile_set = tileset
	tilemap_top_trans.tile_set = tileset
	#shadows.tile_set = tileset

func set_autotiler_cfg_bottom(cfg):
	autotiler_cfg_bottom = cfg
	
func set_autotiler_cfg_top(cfg):
	autotiler_cfg_top = cfg	
	
func update_tileset(tset):
	tileset = tset
	if Engine.editor_hint:
		tilemap_bottom.tile_set = tileset
		tilemap_top.tile_set = tileset
		#shadows.tile_set = tileset
	
	
func clear_transparent_walls():
	pass
	#tilemap_bottom_trans.set('tile_data', [])
	#tilemap_top_trans.set('tile_data', [])

func undo_shrink_wall_tile(tile):
	
	var cell_1 = tilemap_top_trans.get_cell(tile.x, tile.y-1)
	var autotile_coords_1 = tilemap_top_trans.get_cell_autotile_coord(tile.x, tile.y-1)
	var cell_2 = tilemap_top_trans.get_cell(tile.x, tile.y-2)
	var autotile_coords_2 = tilemap_top_trans.get_cell_autotile_coord(tile.x, tile.y-2)
	
	tilemap_top.set_cell(tile.x, tile.y-2, cell_2, false, false, false, autotile_coords_2)
	tilemap_top.set_cell(tile.x, tile.y-1, cell_1, false, false, false, autotile_coords_1)
	
	tilemap_bottom_trans.set_cell(tile.x, tile.y, -1)
	tilemap_bottom.set_cell(tile.x, tile.y, 4)
	
	
	#tilemap_bottom.set_cell(tile.x, tile.y, 4)
	#tilemap_bottom.set_cell(tile.x, tile.y-1, 4)
	
	#var autotile_coords = tilemap_top.get_cell_autotile_coord(tile.x, tile.y-1)
	
	#move current autotile cell, two positions up
	#assert(tile in shrink_wall_cache)
	#var cache = shrink_wall_cache[tile]
	#var cell = cache[0]
	#var autotile_coords = cache[1]
	#shrink_wall_cache.erase(tile)
	#var cell = tilemap_top.get_cell(tile.x, tile.y)
	#var autotile_coords = tilemap_top.get_cell_autotile_coord(tile.x, tile.y)
	#tilemap_top.set_cell(tile.x, tile.y-2, cell, false, false, false, autotile_coords)
	#print('Undo Shrinking', tile)
	
	#tilemap_top.set_cell(tile.x, tile.y, -1)
	#tilemap_top.set_cell(tile.x, tile.y, -1)
	
func shrink_wall_tile(tile):
	
	#bring the same tile id in the top to the bottom region
	
	#make bottom tile(s) transparent
	
	
	#Let's start by removing the tiles
	#var cell = tilemap_top.get_cell(tile.x, tile.y-1)
	#tilemap_top.set_cell(tile.x, tile.y-1, -1)
	#tilemap_top.set_cell(tile.x, tile.y+1, cell)
	
	#move current autotile cell, two positions down
	
	var cell_1 = tilemap_top.get_cell(tile.x, tile.y-1)
	var autotile_coords_1 = tilemap_top.get_cell_autotile_coord(tile.x, tile.y-1)
	var cell_2 = tilemap_top.get_cell(tile.x, tile.y-2)
	var autotile_coords_2 = tilemap_top.get_cell_autotile_coord(tile.x, tile.y-2)
	
	#set cells in the transparent tilemap 
	tilemap_top_trans.set_cell(tile.x, tile.y-1, cell_1, false, false, false, autotile_coords_1)
	tilemap_top_trans.set_cell(tile.x, tile.y-2, cell_2, false, false, false, autotile_coords_2)
	
	
	#tilemap_top.set_cell(tile.x, tile.y, cell_2, false, false, false, autotile_coords_2)
	tilemap_top.set_cell(tile.x, tile.y-2, -1)
	tilemap_top.set_cell(tile.x, tile.y-1, -1)
	
	#tilemap_top.set_cell(tile.x, tile.y-1, -1)
	#tilemap_top.set_cell(tile.x, tile.y-1, cell, false, false, false, Vector2(0,0))
	#print('Shrinking', tile)
	
	tilemap_bottom_trans.set_cell(tile.x, tile.y, 4)
	
	
	tilemap_bottom.set_cell(tile.x, tile.y, -1)
	
	
	
	
	
	
	
	pass
	
func add_chunk(chunk_coord, rect, data):
	#Compute two autotilers for top and bottom levels
	var autotiler_0 = Autotilemap.new()
	var autotiler_1 = Autotilemap.new()

	var br = rect.get_bottom_right()
	var tl = rect.get_top_left()
	var sizex = br.get_x() - tl.get_x()
	var sizey = br.get_y() - tl.get_y()
	
	#TODO: avoid this loop (do it in the module)
	autotiler_0.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()), Vector2(br.get_x(), br.get_y()), autotiler_cfg_bottom)
	
	#set data in a higher row (2x) for the top level map
	autotiler_1.init(Vector2(chunk_coord.get_x(), chunk_coord.get_y()), Vector2(tl.get_x(), tl.get_y()-2), Vector2(br.get_x(), br.get_y()-2), autotiler_cfg_top)
	
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
	
	tilemap_bottom.clear()
	tilemap_top.clear()
	tilemap_bottom_trans.clear()
	tilemap_top_trans.clear()
	
	#tilemap_bottom.set('tile_data', [])
	#tilemap_top.set('tile_data', [])
	#tilemap_bottom_trans.set('tile_data', [])
	#tilemap_top_trans.set('tile_data', [])
	#shadows.set('tile_data', [])

func refresh():
	var chunks_0 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_0)
	var chunks_1 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_1)
	
	var full_wallmap_0 = merge_maps(chunks_0, autotiler_cfg_bottom)
	var full_wallmap_1 = merge_maps(chunks_1, autotiler_cfg_top)
	if full_wallmap_0:
		full_wallmap_0.apply(tilemap_bottom)
		#full_wallmap_0.apply(shadows)
		
	if full_wallmap_1:
		full_wallmap_1.apply(tilemap_top)
	
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
	var full_wallmap_0 = merge_maps(chunks_0, autotiler_cfg_bottom)
	if full_wallmap_0:
		full_wallmap_0.apply(tilemap_bottom)
		#full_wallmap_0.apply(shadows)
		
	var chunks_1 = get_3x3_autotilers(GameEngine.context.get_current_chunk(), map_chunks_1)
	var full_wallmap_1 = merge_maps(chunks_1, autotiler_cfg_top)
	if full_wallmap_1:
		full_wallmap_1.apply(tilemap_top)

func select_object(tile):
	var cell = tilemap_bottom.get_cell(tile.x, tile.y)
	$ObjectSelectLayer.set_cell(tile.x, tile.y, cell)

func unselect_object(tile):
	$ObjectSelectLayer.set_cell(tile.x, tile.y, 0)

func clear():
	map_data = {}
	tilemap_bottom.clear()
	tilemap_top.clear()
	tilemap_bottom_trans.clear()
	tilemap_top_trans.clear()
	#shadows.clear()
