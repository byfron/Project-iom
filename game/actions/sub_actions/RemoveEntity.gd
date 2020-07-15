extends Node

func process(context, delta):
	pass

func start(action, context):
	pass
	
func on_state_changed(action, context):
	pass

func execute_impl(action, context):
	var actor = action.get_map_node(context)
	context.kill_entity(action.entity)
	pass

func on_finish(action, context):
	pass
	
