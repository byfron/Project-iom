extends Node
tool

export var animation = ""
export var state_frames = []

func process(context, delta):
	pass

func start(action, context):
	var node = context._entity2node[action.entity.id]
	node.set_animation(animation)

func on_state_changed(action, context):
	var node = context._entity2node[action.entity.id]
	#node.set_animation(animation)
	node.anim_frame_forward()
	
func execute_impl(action, context):
	pass
#	var node = context._entity2node[action.entity.id]
#	node.anim_frame_forward()
