extends Node

var FSMModule = preload('res://game/utils/FSM.gd').new()
var InputStates = preload('res://game/core/states/InputStates.gd')
const ActionTypes = preload("res://game/actions/ActionTypes.gd")
#const ActionType = preload("res://game/actions/ActionTypes.gd").ActionType
var _fsm = null

func init():
	_fsm = FSMModule.FSM.new()
	var default_state = InputStates.DefaultInputState.new()
	var sprint_state = InputStates.SprintInputState.new()
	var attack_state = InputStates.AttackInputState.new()
	var crouch_state = InputStates.CrouchInputState.new()
	var use_state = InputStates.UseInputState.new()
	var sin_default_state = InputStates.SinDefaultInputState.new()
	var sin_magic_state = InputStates.SinMagicInputState.new()
	var investigate_state = InputStates.InvestigateInputState.new()
	var dead_state = InputStates.DeadState.new()
	
	var regular_states = [sprint_state, attack_state, crouch_state, use_state, investigate_state]
	
	default_state.add_transition('enable_sin', sin_default_state)
	
	sin_default_state.add_transition('disable_sin', default_state)
	sin_default_state.add_transition('fire_zone_magic', sin_magic_state)
	
	default_state.add_transition('attack_action', attack_state)
	default_state.add_transition('use_action', use_state)
	default_state.add_transition('crouch_action', crouch_state)
	default_state.add_transition('sprint_action', sprint_state)
	default_state.add_transition('investigate_action', investigate_state)
	
	#Add cancel and death transition from every state
	default_state.add_transition("dead_state", dead_state)
	for state in regular_states:
		state.add_transition("dead_state", dead_state)
		state.add_transition("cancel_state", default_state)
	
	#crouch does not get canceled, we transition with stand_action
	crouch_state.add_transition('stand_action', default_state)
	
	
	_fsm._current_state = default_state
	
func get_current_state():
	return _fsm._current_state
	
#func cancel_status(action_type):
#	match action_type:
#		ActionTypes.ActionType.CROUCH:
#			_fsm.emit('cancel_state')

func process_item(item_entity):
	var pentity = GameEngine.context.get_player_entity()
	var action = ActionFactory.create_pick_item_action(pentity, null, item_entity)
	SignalManager.emit_signal('send_action', action)

	
static func action_type_to_fsm_signal(action_type):
	var action_to_signal_map = {
		ActionTypes.ActionType.MAGIC_FIRE_ZONE: "fire_zone_magic",
		ActionTypes.ActionType.ATTACK: "attack_action",
		ActionTypes.ActionType.USE: "use_action",
		ActionTypes.ActionType.INVESTIGATE: "investigate_action",
		ActionTypes.ActionType.WALK: "cancel_state"
	}
	if action_type in action_to_signal_map:
		return action_to_signal_map[action_type]
	else:
		return "unrecognized_signal"

func process_status(action_type):
	match action_type:
		ActionTypes.ActionType.DEAD:
			_fsm.emit('dead_state')
		ActionTypes.ActionType.WALK:
			_fsm.emit('cancel_state')
		ActionTypes.ActionType.SPRINT:
			_fsm.emit('cancel_state')
			_fsm.emit('sprint_action')
		ActionTypes.ActionType.CROUCH:
			_fsm.emit('cancel_state')
			_fsm.emit('crouch_action')
		ActionTypes.ActionType.STAND:
			_fsm.emit('cancel_state')
			_fsm.emit('stand_action')
	
#TODO we can refactor this as a regular action
func process_activate_sin():
	_fsm.emit('enable_sin')
	
func process_deactivate_sin():
	_fsm.emit('disable_sin')	
			
			
#The explicit flag indicates if the action has been activated explicitly (through the interface)
#or implicitly through the default actions (i.e mouse over entity)
func process_action(action_type, explicit=true):
	_fsm.emit(action_type_to_fsm_signal(action_type))
	
	if action_type != ActionTypes.ActionType.WALK:
		_fsm._current_state._explicit = explicit
	else:
		_fsm._current_state._explicit = false
#
#	match action_type:
#		ActionType.ATTACK:
#			_fsm.emit('attack_action')
#		ActionType.USE:
#			_fsm.emit('use_action')
#		_:
#			print("Action", action_type, " not recognized.")
