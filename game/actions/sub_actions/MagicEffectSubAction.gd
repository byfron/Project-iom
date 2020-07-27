extends Node
tool

export var color = Color(1.0, 1.0, 1.0)
#export var state_frames = []
#export(CurveTexture) var anim_curve

func process(context, delta):
	pass

func start(action, context):
	pass
	#var node = context._entity2node[action.entity.id]
	#node.orientCharacterTowards(action.from_tile)
	
	#var node = context._entity2node[action.entity.id]
	
	#node.set_frame(state_frames[-1])
	

func on_state_changed(action, context):
	pass
#	if action.current_state < len(state_frames):
#		var node = context._entity2node[action.entity.id]
#		node.set_animation(animation)
#		node.set_frame(state_frames[action.current_state])

func execute_impl(action, context):
	
	#here change the status?
	
	pass
