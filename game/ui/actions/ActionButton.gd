extends Control
tool

enum Test {TA=0, TB}

const ActionTypes = preload("res://game/actions/ActionTypes.gd")

export(Texture) var image setget assign_image
export(ActionTypes.ActionType) var action_type = ActionTypes.ActionType.LOOK
export(Color) var color setget set_color

func set_color(col):
	color = col
	if Engine.editor_hint:
		var new_style = $MarginContainer/Panel.get_stylebox("panel").duplicate()
		new_style.set_bg_color(color)
		$MarginContainer/Panel.set("custom_styles/panel", new_style)

func assign_image(im):
	image = im
	$MarginContainer/MarginContainer/Icon.texture = im

func _ready():
	var new_style = $MarginContainer/Panel.get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	$MarginContainer/Panel.set("custom_styles/panel", new_style)
	
func highlight():
	$Highlight.show()

func unhighlight():
	$Highlight.hide()

func _on_Control_mouse_entered():
	pass # Replace with function body.

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT:
			highlight()
			SignalManager.emit_signal('action_button_pressed', action_type)
