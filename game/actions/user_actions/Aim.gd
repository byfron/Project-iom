extends "UserAction.gd" 

var aimed_tile = null

func start_impl(context):
	var node = get_map_node(context)
	
	#TODO: The aim is be wrong because it's not the inmediate neighbor. 
	#Smooth it somehow
	node.orientCharacterTowards(aimed_tile)

func execute_impl(action, context):
	pass
	#var attacking_node = context._entity2node[action.entity.id]

func on_finish(context):
	#var node = get_map_node(context)
	#node.magic(false)
	pass
