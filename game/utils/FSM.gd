extends Node

class FSMState:
	
	var _transitions = {}
	var _object_instance = null
	
	func _init():
		pass
		#_object_instance = object_instance
		
	func _process(delta):
		pass
		
	func add_transition(signal_key, next_state):
		_transitions[signal_key] = next_state
		
	func on_enter():
		pass
		
	func on_exit():
		pass
		
	func get_next_state(key):
		if _transitions.has(key):
			return _transitions[key]
		return null
	
class FSM:
	var _current_state = null
	signal fsm_event(key)

	func _init():
		connect('fsm_event', self, '_on_event')
		
	func emit(key):
		emit_signal('fsm_event', key)
	
	func _process(delta):
		if _current_state:
			_current_state._process(delta)
		
	func _on_event(key):
		var next_state = _current_state.get_next_state(key)
		if next_state:
			_current_state.on_exit()
			_current_state = next_state
			_current_state.on_enter()
