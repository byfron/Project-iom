extends MarginContainer
tool

export(Texture) var image setget assign_image
export(Color) var color setget set_color
export(Color) var edge_color setget set_edge_color
var _activated = false

var normal_glow = Color(1.0,1.0,1.0, 1.0)
var sin_glow = Color(10.0, 1.0, 1.0, 1.0)
var glow_values = [normal_glow, sin_glow]

func set_color(col):
	color = col
	if Engine.editor_hint:
		var new_style = $Panel.get_stylebox("panel").duplicate()
		new_style.set_bg_color(color)
		$Panel.set("custom_styles/panel", new_style)

func set_edge_color(col):
	edge_color = col
	if Engine.editor_hint:
		$TextureRect.modulate = edge_color

func assign_image(im):
	image = im
	if Engine.editor_hint:
		$MarginContainer/Icon.texture = im

func _ready():
	$MarginContainer/Icon.texture = image
	var new_style = $Panel.get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	$Panel.set("custom_styles/panel", new_style)
	$TextureRect.modulate = edge_color

func start_glow():
	$Tween.interpolate_property(self, "modulate", glow_values[0], glow_values[1], 1.0, Tween.EASE_IN, Tween.EASE_OUT)
	$Tween.start()
	
func finish_glow():
	glow_values = [normal_glow, sin_glow]
	self.modulate = normal_glow
	$Tween.stop_all()
	
func activate():
	_activated = true
	SignalManager.emit_signal("activate_sin")
	start_glow()
	
func deactivate():
	_activated = false
	SignalManager.emit_signal("deactivate_sin")
	finish_glow()
	
func _on_SinButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT:
			if not _activated:
				activate()
			else:
				deactivate()

func _on_Tween_tween_completed(object, key):
	glow_values.invert()
	start_glow()
