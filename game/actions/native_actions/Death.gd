extends "res://game/actions/Action.gd"
var ECS = load('res://game/core/proto/ecs.gd')
	
	
func start_impl(context):
	pass
	
func process_impl(context, turn_time):
	
	#TODO: this can be generalized for all "auto" actions
	var normalized_action_time = get_normalized_action_time(turn_time)
	#force state change
	var state = int(normalized_action_time * num_states)
	if state > current_state:
		change_state(context)

func on_state_changed(action, context):
	pass

func execute_impl(action, context):
	#remove initiative component from entity, so that it's not an active entity
	action.entity.remove('initiative')
	
	if 'inventory' in action.entity.components:
		#create container component with inventory items
		var container = Utils.inventory_to_container(action.entity.components['inventory'])
		action.entity.components['container'] = container
	
	#make node z level at the "ground level" so that we always step over it
	var node = context._entity2node[action.entity.id]
	node.z_index -= 1
	
	#tmp if items in container?
	node.loot_effect.show()
