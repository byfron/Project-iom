extends Node2D
var Response = load("res://game/ui/panels/Response.tscn")

func _ready():
	pass

func set_dialog(dialog):
	var dialog_state = dialog.get_current_state()
	$MarginContainer/VSplitContainer/MarginContainerTop/DialogTextLabel.text = dialog_state.text
	var response_container = $MarginContainer/VSplitContainer/MarginContainer/Responses
	Utils.delete_children(response_container)
	
	for option in dialog_state.options:
		var response = Response.instance()
		response._text = option.text
		response._dialog_id = option.next_state_id
		response_container.add_child(response)
