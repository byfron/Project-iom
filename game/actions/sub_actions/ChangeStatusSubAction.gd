extends Node
tool
var ActionFactory = load('res://game/core/ActionFactory.gd').new()

func process(context, delta):
	pass

func on_state_changed(action, context):
	pass
	
func execute_impl(action, context):
	var entity_list = context._tile2entity[action.attacked_tile]
	for entity in entity_list:
		var node = context.get_entity_node(entity)
		node.frozen(true)

func start(action, context):
	
	#set frost
	
	pass
