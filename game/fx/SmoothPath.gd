tool
class_name SinChain
extends Path2D

export(float) var spline_length = 100
export(bool) var _smooth setget smooth
export(bool) var _straighten setget straighten
export(float) var thickness = 1
export(Vector2) var point_a setget set_point_a
export(Vector2) var point_b setget set_point_b
var box = Box.new(Vector2(0,0), Vector2(0,0), 20.0)
var _num_divisions = 3
var _goal_vector = []
var _gaussian_means = []

class Box:
	var a = Vector2(0,0)
	var b = Vector2(0,0)
	var c = Vector2(0,0)
	var d = Vector2(0,0)
	var _width = 10
	
	func update(p1, p2):
		var dir = p2 - p1
		var perp = Vector2(dir.y, -dir.x)
		perp = perp.normalized()
		a = p1 + _width * perp/2.0
		b = p1 - _width * perp/2.0
		c = p2 - _width * perp/2.0
		d = p2 + _width * perp/2.0
	
	func get_points():
		var points = PoolVector2Array()
		points.append(a)
		points.append(b)
		points.append(c)
		points.append(d)
		return points
	
	func _init(p1, p2, width):
		_width = width
		update(p1, p2)
	
func set_point_a(p):
	point_a = p
	recompute()
	
func set_point_b(p):
	point_b = p
	recompute()
	
func recompute():
	#box.update(point_a, point_b)
	curve.clear_points()
	_goal_vector = []
	_gaussian_means = []
	
	#compute number of divisions
	var main_vec = point_b - point_a
	box._width = main_vec.length()/8.0
	var perp = Vector2(main_vec.y, -main_vec.x).normalized()
	var norm_main_vec = main_vec.normalized()
	_num_divisions = 3
	
	var displacement = box._width
	var num_points = _num_divisions + 2
	var division_length = main_vec.length() / (num_points - 1)
	curve.add_point(point_a)
	_goal_vector.append(point_a)
	_gaussian_means.append(point_a)
	for i in _num_divisions:
		var shift = Vector2(0,0)
		if i%2 == 0:
			shift = perp*displacement
		else:
			shift = -perp*displacement
			
		var point = point_a + (i+1) * norm_main_vec * division_length + shift
		var rnd_offset = Vector2(randf(), randf()).normalized()
		_goal_vector.append(point + rnd_offset * box._width * 2.0)
		_gaussian_means.append(point)
		curve.add_point(point)
		
		
	curve.add_point(point_b)
	_gaussian_means.append(point_b)
	_goal_vector.append(point_b)
	print('===')
	print(curve.get_point_count())
	update()
	smooth(true)
	
func straighten(value):
	if not value: return
	for i in curve.get_point_count():
		curve.set_point_in(i, Vector2())
		curve.set_point_out(i, Vector2())

func smooth(value):
	
	if not value: return
	
	var point_count = curve.get_point_count()
	for i in point_count-2:
		var spline = _get_spline(i+1)
		curve.set_point_in(i+1, -spline)
		curve.set_point_out(i+1, spline)

func _ready():
	box = Box.new(Vector2(0,0), Vector2(0,0), 20.0)
	
func _get_spline(i):
	var last_point = _get_point(i - 1)
	var next_point = _get_point(i)
	var spline = last_point.direction_to(next_point) * spline_length
	return spline

func _get_point(i):
	var point_count = curve.get_point_count()
	i = wrapi(i, 0, point_count - 1)
	return curve.get_point_position(i)

func _process(delta):
	#move points with noise
	var point_count = curve.get_point_count()
	
	#move towards goal
	for i in point_count-2:
		var pos = curve.get_point_position(i+1)
		var goal = _goal_vector[i+1] 
		if (pos - goal).length() < 2:
			#choose new goal
			var rnd_offset = Vector2(randf(), randf()).normalized()
			goal = _gaussian_means[i+1] + rnd_offset * box._width * 2.0
			_goal_vector[i+1] = goal
			
		var offset = (0.95*pos + 0.05*goal) - pos
		pos += offset
		curve.set_point_position(i+1, pos)
	
	update()
	#print(point_count)
	#for i in point_count-2:
	#	var pos = curve.get_point_position(i+1)
	#	pos += Vector2(randi()%20+1, randi()%20+1) - Vector2(10,10)
	#	curve.set_point_position(i+1, pos)
		
	#update()
	#curve.set_bake_interval(10.0)

func _draw():
	
	var points = curve.get_baked_points()
	#TODO: instead of this... just use a regular Line2D so that we can UV texture it and add effects in a shader
	if points:
		draw_polyline(points, Color.red, thickness, true)
		
	#if box:
	#	draw_polyline(box.get_points(), Color.black, 10, true)
		
