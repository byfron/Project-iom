extends Node 

var _startx = 0
var _starty = 0
var _radius = 0
var _rStrat = 0
var _resistanceMap = 0
var lightMap = {}
var _width = 0
var _height = 0
var radius = 20

func tile_is_blocked(map, axial_coords):
	return axial_coords in map
	
class Strat:
	func radius(a, b):
		return sqrt(a*a + b*b)

# http://www.roguebasin.com/index.php?title=Improved_Shadowcasting_in_Java
# Calculates the Field Of View for the provided map from the given x, y
# coordinates. Returns a lightmap for a result where the values represent a
#  percentage of fully lit.
func calculateFOV(resistanceMap, startx, starty, width, height, radius):
	_startx = startx;
	_starty = starty;
	_radius = radius;
	_rStrat = Strat.new();
	_resistanceMap = resistanceMap;
	
	var DIAGONALS = [[-1, 0], [0, -1], [1, -1], [1, 0], [0, 1], [-1, 1], [1, 1], [-1,-1]]
	
	var player = GameEngine.context.get_player_node()
	var top_left = Vector2(player.coords.x, player.coords.y) - Vector2(35, 25) # - Vector2(width, height)/2
	var bottom_right = Vector2(player.coords.x, player.coords.y) + Vector2(40, 25)
	
	width = bottom_right.x - top_left.x
	height = bottom_right.y - top_left.y
	_width = width
	_height = height
	
	var light_map = Autotilemap.new()
	light_map.init(top_left, bottom_right, "res://game_assets/tilemap_meta/fov_blob.json")
	
	#var light_map = load("res://game/utils/Tilematrix.gd").new()
	#light_map.init(width, height, top_left, bottom_right, "res://game_assets/tilemap_meta/fov_blob.json")

	light_map.set_value_relative_to_tl(startx, starty, 0) # force //light the starting cell
	for d in DIAGONALS:
		castLight(light_map, 1, 1.0, 0.0, 0, d[0], d[1], 0)
		castLight(light_map, 1, 1.0, 0.0, d[0], 0, 0, d[1])
		
	return light_map
	
func castLight(light_map, row, start, end,  xx,  xy,  yx,  yy):
	var newStart = 0.0
	if (start < end):
		return;
	
	var blocked = false;
	for distance in range(row, radius):
		if blocked:
			break
			
		var deltaY = -distance
		for deltaX in range(-distance, 0):
			var currentX = _startx + deltaX * xx + deltaY * xy
			var currentY = _starty + deltaX * yx + deltaY * yy
			var leftSlope = (deltaX - 0.5) / (deltaY + 0.5)
			var rightSlope = (deltaX + 0.5) / (deltaY - 0.5)
		
			if start < rightSlope:
				continue;
			elif end > leftSlope:
				break;
			
			#check if it's within the lightable area and light if needed
			var delta_radius = _rStrat.radius(deltaX, deltaY)
			if (delta_radius <= radius):
				var bright = 1 - (delta_radius / radius)
				#if not Vector2(currentX, currentY) in _resistanceMap: 
				light_map.set_value_relative_to_tl(currentX, currentY, 0)
			
			if blocked: #previous cell was a blocking one
				if  Vector2(currentX, currentY) in _resistanceMap: #hit a wall
					newStart = rightSlope
					continue
				else:
					blocked = false
					start = newStart
			else:
				if Vector2(currentX,currentY) in _resistanceMap and distance < radius: #hit a wall within sight line
					blocked = true
					castLight(light_map, distance + 1, start, leftSlope, xx, xy, yx, yy);
					newStart = rightSlope;
