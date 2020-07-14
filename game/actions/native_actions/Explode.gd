extends "res://game/actions/Action.gd"

func on_finish(context):
	#delete bottle entity and node
	
	#bring down the debree if there's elevation? like a bottle exploding
	
	pass
	
func on_state_changed(action, context):
	if current_state == 1:
		var node = context.get_entity_node(entity)
		node.test_crash()
