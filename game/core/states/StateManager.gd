extends Node

var FSMModule = preload('res://game/utils/FSM.gd').new()
var InputStates = preload('res://game/core/states/InputStates.gd')
const ActionType = preload("res://game/actions/ActionTypes.gd").ActionType
var _fsm = null

func init():
	_fsm = FSMModule.FSM.new()
	var default_state = InputStates.DefaultInputState.new()
	var attack_state = InputStates.AttackInputState.new()
	var crouch_state = InputStates.CrouchInputState.new()
	
	default_state.add_transition('attack_action', attack_state)
	default_state.add_transition('use_action', attack_state)
	default_state.add_transition('crouch_action', crouch_state)
	
	attack_state.add_transition('cancel_state', default_state)
	
	
	crouch_state.add_transition('stand_action', default_state)
	#crouch does not get canceled, we transition with stand_action
	
	_fsm._current_state = default_state
	
func get_current_state():
	return _fsm._current_state
	
func cancel_status(action_type):
	match action_type:
		ActionType.CROUCH:
			_fsm.emit('cancel_state')

func process_item(item_entity):
	var pentity = GameEngine.context.get_player_entity()
	var action = ActionFactory.create_pick_item_action(pentity, null, item_entity)
	SignalManager.emit_signal('send_action', action)

func process_status(action_type):
	match action_type:
		ActionType.CROUCH:
			_fsm.emit('crouch_action')
		ActionType.STAND:
			_fsm.emit('stand_action')
			
func process_action(action_type):
	match action_type:
		ActionType.ATTACK:
			_fsm.emit('attack_action')
		ActionType.USE:
			_fsm.emit('use_action')
		_:
			print("Action", action_type, " not recognized.")
