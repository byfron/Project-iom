extends Area2D

var _status = "idle"
var _clicked_pos = null
var _current_pos = null
var _world_map = null
var _button_container = null
var _map_node_initial_pos = Vector2(0,0)
var _mobile = false
var ActionFactory = load('res://game/core/ActionFactory.gd').new()

var movement_keys = [KEY_Q, KEY_W, KEY_E, KEY_D, KEY_A, KEY_Z, KEY_X, KEY_C]

func process_movement_event(event):
	var entity = GameEngine.context.get_player_entity()
	var coords = Utils.get_entity_location(entity)#GameEngine.context.get_current_tile()
		
	var crouching = entity.components['char_status'].get_crouching()
		
	var offset = parse_movement_event(event)
	coords.x += offset.x
	coords.y += offset.y
		
	var default_actions = ActionFactory.create_default_movement_actions(entity, coords)
		
	if default_actions:
		for action in default_actions:
			SignalManager.emit_signal('send_action', action)
	else:
		SignalManager.emit_signal('send_action', ActionFactory.create_movement_action(entity, [coords]))

func is_movement_event(event):
	if event.control or event.shift or event.alt:
		return false
		
	for mk in movement_keys:
		if mk == event.scancode:
			return true
			
	return false

func parse_movement_event(event):
	var coords = Vector2(0,0)
	if event.scancode == KEY_Q:
		coords.y -= 1
		coords.x -= 1
	elif event.scancode == KEY_W:
		coords.y -= 1
	elif event.scancode == KEY_E:
		coords.y -= 1
		coords.x += 1
	elif event.scancode == KEY_D:
		coords.x += 1
	elif event.scancode == KEY_A:
		coords.x -= 1
	elif event.scancode == KEY_Z:
		coords.y += 1
		coords.x -= 1
	elif event.scancode == KEY_X:
		coords.y += 1
	elif event.scancode == KEY_C:
		coords.y += 1
		coords.x += 1
		
	return coords
		

func _ready():
	connect("input_event", self, "_on_Area2D_input_event")

func compute_neighbor_from_direction(pos):
	var deg = rad2deg(pos.angle())
	var idx = 0
	deg += 90 + 45.0/2
	if deg < 0:
		deg += 360
		
	var current_angle = 0
	for i in range(8):
		if deg >= idx*45 and deg <= (idx+1)*45:
			return idx
		idx += 1

	return 0

func _on_Area2D_input_event(viewport, event, shape_idx ):
	GameEngine.get_current_state().process_mouse_input(event)
			
func _unhandled_input(event):
	#TODO: This seems very inefficient
	SignalManager.emit_signal("mouse_out_of_gui")

func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	
	if just_pressed and event is InputEventKey:
		
		#Reddit rain DEMO
		if event.scancode == KEY_R:
			GameEngine.context.world.scene_color_canvas.start_rain()
			
			pass
			
		var state = GameEngine.get_current_state()
		GameEngine.get_current_state().process_keyboard_input(event, self)
	

