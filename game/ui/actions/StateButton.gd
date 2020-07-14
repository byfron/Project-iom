extends MarginContainer
tool

const ActionTypes = preload("res://game/actions/ActionTypes.gd")

export(Texture) var image setget assign_image
export(ActionTypes.ActionType) var pressed_action_type = ActionTypes.ActionType.LOOK
export(ActionTypes.ActionType) var released_action_type = ActionTypes.ActionType.LOOK
export var pressed = false setget press_button

func press_button(flag):
	pressed = flag
	if flag:
		$PanelContainer.texture = load('res://game_assets/gui/pressed_button.png')
		$MarginContainer/MarginContainer.set("custom_constants/margin_top", 10)
		$MarginContainer/MarginContainer.set("custom_constants/margin_bottom", 7)
		$MarginContainer/MarginContainer/Icon.self_modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		$PanelContainer.texture = load('res://game_assets/gui/unpressed_button.png')
		$MarginContainer/MarginContainer.set("custom_constants/margin_bottom", 10)
		$MarginContainer/MarginContainer.set("custom_constants/margin_top", 7)
		$MarginContainer/MarginContainer/Icon.self_modulate = Color(0.0, 0.0, 0.0, 0.5)
		
func assign_image(im):
	image = im
	$MarginContainer/MarginContainer/Icon.texture = im

func _ready():
	pass
	
func highlight():
	$Highlight.show()

func unhighlight():
	$Highlight.hide()

func _on_Control_mouse_entered():
	pass # Replace with function body.

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT:
			if pressed: 
				press_button(false)
				SignalManager.emit_signal('status_button_released', released_action_type)
			else:
				press_button(true)
				SignalManager.emit_signal('status_button_pressed', pressed_action_type)
