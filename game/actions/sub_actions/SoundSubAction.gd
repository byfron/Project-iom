extends Node
tool

export var sound = ""

func process(context, delta):
	pass

func start(action, context):
	pass
	
func on_state_changed(action, context):
	pass

func execute_impl(action, context):
	var actor = context._entity2node[action.entity.id]
	
	#TODO: SoundManager.get_node(sound).play()
	actor.get_node("FX").get_node(sound).play()
