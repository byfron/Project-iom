extends "res://game/actions/Action.gd"
var from_tile = null

func execute_impl(action, context):
	#action.entity
	var node = context._entity2node[action.entity.id]
	node.orientCharacterTowards(from_tile)
	node.surprised(true)
