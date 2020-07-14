extends Node

var state_map = {}
var FSMModule = load('res://game/utils/FSM.gd').new()
var _fsm = FSMModule.FSM.new()

#The Talk action starts the dialog when triggered. The talk action does not
#consume turn. 
#The dialog is a state machine, when reaching the final state the talk action ends, 
#and the entity dialog is updated with the next one

class DialogOption:
	var next_state_id = null
	var text = null
	
	func _init(txt, nsid):
		next_state_id = nsid
		text = txt
		
	func get_signal():
		return "dialog_change_to_state_" + str(next_state_id)

class DialogState extends "res://game/utils/FSM.gd".FSMState:
	var text = ""
	var options = []
	var triggers = []
	var final_state = false
	var next_dialog = null
	
	func is_final_state():
		return final_state
	
	func _init():
		pass
		
	func on_enter():
		#send a signal to the dialog panel to display. Update?
		#create_talk_action
		pass
		
	func on_exit():
		#TODO: send triggers
		
		pass
		
	func _process(delta):
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func process_option(dialog_state_id):
	_fsm.emit("dialog_change_to_state_" + str(dialog_state_id))
	
static func create(config_file):
	var sm = load("res://game/dialogs/DialogStateMachine.gd").new()	
	sm.load_config(config_file)
	return sm

func get_current_state():
	return _fsm._current_state

func get_next_dialog():
	return get_current_state().next_dialog

func has_ended():
	if _fsm._current_state.is_final_state():
		return true
	return false

func load_config(config_file):
	var dialog_cfg = Utils.load_from_json(config_file)	
	for state_cfg in dialog_cfg:
		var dialog_state = DialogState.new()
		dialog_state.text = state_cfg['text']
		
		if 'options' in state_cfg:
			for opt_cfg in state_cfg['options']:
				var dialog_option = DialogOption.new(opt_cfg['text'], opt_cfg['next_dialog_state'])
				dialog_state.options.append(dialog_option)
		
		if 'final' in state_cfg:
			dialog_state.final_state = true
			#var dialog_option = DialogOption.new('Finish conversation', -1)
			#dialog_state.options.append(dialog_option)
			
		if 'next_dialog' in state_cfg:
			dialog_state.next_dialog = int(state_cfg['next_dialog'])
			
		state_map[int(state_cfg['state_id'])] = dialog_state
			
	#add signals between states
	for state_id in state_map:
		var state = state_map[state_id]
		for option in state.options:
			var next_state = state_map[int(option.next_state_id)]
			state.add_transition(option.get_signal(), next_state)
	
	#TODO: Fix this magic number (initial state)
	_fsm._current_state = state_map[1]
