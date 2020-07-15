extends "res://game/actions/Action.gd"

func on_finish(context):
	pass
	
func on_state_changed(action, context):
	pass
	
func start_impl(context):
	#Create explosion node
	var node = get_map_node(context)
	node.explode()
	
func execute_impl(action, context):
	pass
