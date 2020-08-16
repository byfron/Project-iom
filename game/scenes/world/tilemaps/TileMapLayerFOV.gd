extends Node2D

onready var tilemap1 = $TileMap_1
onready var tilemap2 = $TileMap_2

var tilemap = null
var map_data = {}
var _hex_grid = null
var _fov = null

onready var FOV = load("res://game/utils/FOV.gd")

func _ready():
	tilemap = tilemap1
	_fov = FOV.new()
	
	
	#$DarkTileMap.set

func set_tilemap(data_array):
	#Darken the sides too
#	var width = get_viewport().size.x/64
#	var height = get_viewport().size.y/64
#	var side_width = width - 2*_fov.radius
#	var side_heighr = height - 2*_fov.radius

	tilemap.set("tile_data", data_array.get_tilemap_array())
