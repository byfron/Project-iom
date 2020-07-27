extends Node
tool

export var animations = [""]

func process(context, delta):
	pass

func start(action, context):
	pass

func on_state_changed(action, context):
	#Choose random anim
	var idx = randi()%len(animations)
	var animation = animations[idx]
	
	var node = context._entity2node[action.entity.id]
	node.set_animation(animation)
	node.set_frame(0)

func execute_impl(action, context):
	pass
