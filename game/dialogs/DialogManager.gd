extends Node

var DialogStateMachine = load("res://game/dialogs/DialogStateMachine.gd")
var dialog_script_path = "res://game/dialogs/"

class Dialog extends Node:
	var _current_dialog = 1
	var _character_dialog_map = {}
	var refresh = true
	
	func get_current_dialog():
		return _character_dialog_map[_current_dialog]
		
	func switch_to_dialog(did):
		_current_dialog = did
		refresh = true
		
	func process_option(dialog_state_id):
		get_current_dialog().process_option(dialog_state_id)
		refresh = true
		
func create_character_dialog(dialog_states):
	
	var dialog = Dialog.new()
	SignalManager.connect("player_chooses_dialog_option", dialog, "process_option")
	
	for dialog_cfg in dialog_states:
		var script = dialog_script_path + dialog_cfg.get_script()
		var dialog_id = int(dialog_cfg.get_id())
		var dsm = DialogStateMachine.create(script)
		dialog._character_dialog_map[dialog_id] = dsm
		dialog.add_child(dsm)
	
	return dialog
