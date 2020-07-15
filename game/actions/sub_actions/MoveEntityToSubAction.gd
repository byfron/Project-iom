extends Node

func process(context, delta):
	pass

func start(action, context):
	pass

func on_state_changed(action, context):
	pass
	
func execute_impl(action, context):
	var tile = action.path.pop_front()
	if not tile:
		return
