extends Node2D
var FSMModule = preload('res://game/utils/FSM.gd').new()
onready var cursor = $Cursor
onready var aimline = $AimLine
onready var gui_tilemap = $GUITilemap

var dir_array = [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1,1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]
		
func _ready():
	pass
	
func process_ranged_attack_mouse_input(event):
	change_to_aim()
	
	pass
	
func display_action(tile, action):
	var scoords = Utils.getScreenCoords(tile)
	var overlay_action = $Action
	overlay_action.show()
	overlay_action.position = Vector2(scoords.x + 32, scoords.y + 70)
	overlay_action.set_text(action.name)
	
func hide_action():
	var overlay_action = $Action
	overlay_action.hide()
	
func change_to_aim():
	cursor.aim_mode()
	
func change_to_select():
	cursor.select_mode()
	
func change_to_normal():
	cursor.select_mode()
	
func show_path():
	pass
	
func draw_smooth_curve(tile_path):
	var scurve = $SmoothPath
	scurve.curve.clear_points()
	scurve.show()
	for tile in tile_path:
		var point = Utils.getScreenCoordsTileCenter(tile)
		scurve.curve.add_point(point)
	scurve.smooth(true)
	scurve.update()
	
func hide_smooth_curve():
	var scurve = $SmoothPath
	#scurve.hide()

func display_tile_path(path):
	gui_tilemap.set('tile_data', [])
	for tile in path:
		gui_tilemap.set_cell(tile.x, tile.y, 0)
		
func hide_aim_line():
	aimline.hide()
	
func set_aim_line(start_point, end_point):
	aimline.show()
	aimline.points[0] = start_point
	aimline.points[1] = end_point

func select_tile(tile):
	var scoords = Utils.getScreenCoords(tile)
	cursor.show()
	cursor.position = scoords
	
func unselect_tile():
	cursor.hide()
	
func hide_motion_grid():
	gui_tilemap.hide()
	
func display_motion_grid(tile):
	gui_tilemap.show()
	gui_tilemap.clear()
	gui_tilemap.set_cell(tile.x, tile.y, 2)
