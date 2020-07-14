extends "ActionButton.gd"
tool

var item_entity = null

func _on_Control_mouse_entered():
	pass # Replace with function body.


#TODO: it'll be more organized to send signals and have somehwere where the actions are created
#(That's the satte manager!')
func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT:
			SignalManager.emit_signal('item_button_pressed', item_entity)
