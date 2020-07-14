extends PanelContainer

var _dialog_id = null
var _text = null
onready var response_label = $HBoxContainer/Label

func _ready():
	response_label.text = _text

func _on_Response_gui_input(event):
	if (event is InputEventMouseButton && event.pressed):
		SignalManager.emit_signal("player_chooses_dialog_option", _dialog_id)

func _on_Response_mouse_entered():
	self_modulate = Color(0.490196, 0.756863, 0.513726)

func _on_Response_mouse_exited():
	self_modulate = Color(0.109804, 0.482353, 0.141176)
	
