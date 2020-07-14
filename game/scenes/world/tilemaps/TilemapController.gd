extends Node2D
tool

onready var fg_node = $FgNode
onready var thread = Thread.new()
var back_buffer_ready = false

signal tilemaps_generated

onready var ground_layer = $FgNode/GroundLayer
onready var overground_layer = $FgNode/OvergroundLayer
onready var dwelling_layer = $FgNode/WallsTilemap #$FgNode/DwellingLayer

var tilemap_stack = {}

enum TILEMAPSTACK {
	GROUND = 1,
	OVERGROUND = 2,
	OBJECT = 3
}

class TileInfo:
	var tile = null
	
func _ready():
	tilemap_stack[TILEMAPSTACK.GROUND] = [ground_layer, overground_layer]
	tilemap_stack[TILEMAPSTACK.OVERGROUND] = [dwelling_layer]
	
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

func refresh():
	for tnode in fg_node.get_children():
		tnode.refresh()
