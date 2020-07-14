tool
extends MarginContainer
onready var label = $HBoxContainer/text
export(String) var log_text setget set_text

func set_text(t):
	log_text = t
	if Engine.editor_hint:
		var label = $HBoxContainer/text
		label.text = t
		
func _ready():
	label.text = log_text
