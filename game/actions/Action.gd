extends Node
tool

var entity = null
export var action_name = ""
export var num_states = 1
export var current_state = -1
export var execution_state = 0
export var priority = 0
export var _consumes_turn = true
export var action_duration = 0.1
export var infinite = false
export var responsive = false

# The action finishes only when reaching the end of the turn time,
# rather than when reaching the final state
export var continuous = false

export var valid_range = 1

#var current_turn_time = 0
var has_finished = false
var has_started = false
var state_duration = 1
var not_yet_executed = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
#func is_turn_finished():
#	if responsive:
#		return true
#
#	if current_state_time >= state_duration:
#		return true
#	return false
	
func process(context, current_turn_time):
	process_impl(context, current_turn_time)
	for sub_action in get_children():
		sub_action.process(context, current_turn_time)
	
func init(ent):
	entity = ent
	
func process_impl(context, delta):
	pass
	
func execute_impl(action, context):
	pass
	
func start_impl(context):
	pass
	
func consumes_turn():
	return _consumes_turn
	
func start(action, context):
	start_impl(context)
	
	for sub_action in get_children():
		sub_action.start(action, context)
		
	current_state = 0
	action_duration = GameEngine.MAX_TURN_TIME * num_states
	
	#TODO: remove this
	#var node = context.get_entity_node(entity)
	#node.set_debug_label(action.name[0] + str(current_state))
	
	#change_state(context)
	
func execute(context):
	execute_impl(self, context)
	for sub_action in get_children():
		sub_action.execute_impl(self, context)

func run_next_turn():
	pass

func finish_action():
	has_finished = true

func is_finished():
	
	if not has_started:
		return false
	
	if continuous and get_normalized_action_time(GameEngine.current_turn_time) >= 1.0:
		return true
	elif current_state+1 == num_states:
		return true
			
	#We can force finish actions with a flag
	if has_finished:
		return true
		
	return false
	
func on_state_changed(action, context):
	pass
	
func get_map_node(context):
	return context._entity2node[entity.id]
	
func on_finish(context):
	pass
	
func get_normalized_action_time(turn_time):
	return min(1, (current_state*GameEngine.MAX_TURN_TIME + turn_time)/action_duration)
	
func change_state(context):

	if not has_started:
		has_started = true
		current_state = 0
	else:
		current_state += 1

	context.world.debug_panel.add_map_entry(entity.id, str(current_state))
	
	if not_yet_executed and current_state >= execution_state:
		execute(context)
		not_yet_executed = false
		
	on_state_changed(self, context)
	for sub_action in get_children():
		sub_action.on_state_changed(self, context)

	#TODO: Remove this
	#var node = context.get_entity_node(entity)
	#node.set_debug_label(str(current_state))
	#current_state_time = 0
	
	
	
	
	#If this is the last state, finish action
	#if current_state+1 == num_states:
	#	finish_action()

