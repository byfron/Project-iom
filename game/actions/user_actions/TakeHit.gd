extends "UserAction.gd"

var damage = 4
var from_tile = null

func start_impl(context):
	var node = context._entity2node[entity.id]
	node.orientCharacterTowards(from_tile)
	
	#node.attacked(true)

func execute_impl(action, context):
	var node = context._entity2node[entity.id]
	node.attacked(true)
	context.world.camera.shakeCamera()
