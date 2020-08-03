extends Node2D
tool

onready var fg_node = $FgNode
onready var thread = Thread.new()
var back_buffer_ready = false

signal tilemaps_generated

onready var ground_layer = $FgNode/GroundLayer
onready var decoration_layer = $FgNode/DecorationLayer
onready var overground_layer = $FgNode/OvergroundLayer
onready var dwelling_layer = $FgNode/WallsTilemap
onready var water_reflections = $FgNode/ReflectionTilemapLayer

var tilemap_stack = {}

class TileInfo:
	var tile = null
	
func _ready():
	tilemap_stack[GameEngine.TILEMAPSTACK.GROUND] = [ground_layer, overground_layer, water_reflections]
	tilemap_stack[GameEngine.TILEMAPSTACK.OVERGROUND] = [dwelling_layer]
	tilemap_stack[GameEngine.TILEMAPSTACK.DECORATION] = [decoration_layer]
	
	dwelling_layer.init()
	
func _process(delta):
	pass
	
func get_tile_info(tile):
	var tile_info = TileInfo.new()
	tile_info.tile = tile
	return tile_info	
#
func update_tilemap(tile, stack, tid):
	var tmaps = tilemap_stack[stack]
	for tnode in tmaps:
		tnode.update_tilemap(tile, tid)

func clear_map_chunks():
	for tmap in tilemap_stack:
		for tnode in tilemap_stack[tmap]:
			tnode.clear_tilemap()
		
func get_3x3_chunks_around_current():
	var current_chunk = GameEngine.context.get_current_chunk()
	var offsets = [[-1, -1], [0, -1], [1, -1], 
				   [-1,  0], [0,  0], [1,  0],
				   [-1,  1], [0,  1], [1,  1]]
	
	var chunk_coords = []
	for offset in offsets:
		chunk_coords.append(Vector3(current_chunk.x + offset[0], current_chunk.y + offset[1], current_chunk.z))

	return chunk_coords
	
func add_chunks_from_map(chunk_map, chunk_coords):
	for coord in chunk_coords:
		if coord in chunk_map:
			add_chunk(chunk_map[coord])
		else:
			print('WARNING: coord ' + str(coord) + ' not in chunk map')

func add_chunk(chunk):
	var chunk_coord = chunk.get_coord()
	var tilemap_array = chunk.get_tilemap()

	for tilemap in tilemap_array:
		var rect = tilemap.get_rect()
		var type = tilemap.get_type()
		if type in tilemap_stack:
			for tmap in tilemap_stack[type]:
				tmap.add_chunk(chunk_coord, rect, tilemap.get_data())
				
				
#	#Find water tiles to prepare reflection
#	var tdata = tilemap_array[0].get_data()
#	var rect = tilemap_array[0].get_rect()
#	var tl = rect.get_top_left()
#	var br = rect.get_bottom_right()
#	var width = br.get_x() - tl.get_x()
#	var height = br.get_y() - tl.get_y()
#
#
#
#	for tx in range(width):
#		for ty in range(height):
#			var tile = tdata[ty * width + tx]
#			print(tile)
#			if tile == 48: #WATER
#				var x = tl.get_x() + tx
#				var y = tl.get_y() + ty
#
#				#Let's start by adding those tiles to the 
#				#reflection tilemap. We could as well have a ColorCanvas
#				var autotile_coords = overground_layer.tilemap.get_cell_autotile_coord(x, y)
#				var cell_id = overground_layer.tilemap.get_cell(x, y)
#				GameEngine.context.world.world_map.water_reflections.set_cell(x, y, cell_id, false, false, false, autotile_coords)
#				pass
			
	
	pass

func refresh():
	for tnode in fg_node.get_children():
		tnode.refresh()
		
	postprocess_water_reflections()

func postprocess_water_reflections():
	
	#go through tiles of water, changing to corresponding atlas id depending on
	#how close to the north shore the tile is
	var tilemap = water_reflections.tilemap
	var used_cells = tilemap.get_used_cells()
	
	var tiledata = tilemap._get_tile_data()
	var num_cells = len(tiledata)/3
	
	var cell_map = {}
	for tidx in range(num_cells):
		var tdata = tiledata[tidx*3]
		pass
	
	for cell in used_cells:
		cell_map[cell] = 1

	for cell in cell_map:
		if not Vector2(cell.x, cell.y-1) in cell_map:
			var autotile_c = tilemap.get_cell_autotile_coord(cell.x, cell.y)
			var id = tilemap.get_cell(cell.x, cell.y)
			#change to the first atlas
			tilemap.set_cell(cell.x, cell.y, 0, false, false, false, autotile_c)
	
		elif not Vector2(cell.x, cell.y-2) in cell_map:
			var autotile_c = tilemap.get_cell_autotile_coord(cell.x, cell.y)
			#change to the second atlas
			tilemap.set_cell(cell.x, cell.y, 1, false, false, false, autotile_c)
	
		else:
			var autotile_c = tilemap.get_cell_autotile_coord(cell.x, cell.y)
			#change to the third atlas
			tilemap.set_cell(cell.x, cell.y, 2, false, false, false, autotile_c)
	pass
