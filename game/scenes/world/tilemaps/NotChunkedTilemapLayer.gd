extends Node2D

onready var tilemap = $Tilemap
export(TileSet) var tileset setget update_tileset
export(String) var autotiler_cfg setget set_autotiler_cfg
var _autotiler = null

func _ready():
	tilemap.tile_set = tileset

func init():
	pass
	#autotiler.init(Vector2(0,0), top_left, b, autotiler_cfg)

func set_autotiler_cfg(cfg):
	autotiler_cfg = cfg
	
func update_tileset(tset):
	tileset = tset
	if Engine.editor_hint:
		tilemap.tile_set = tileset
		
func set_tile(pos, tid):
	_autotiler.set_value_relative_to_tl(pos.x, pos.y, tid)
