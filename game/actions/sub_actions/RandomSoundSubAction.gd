extends Node
tool
var rng = RandomNumberGenerator.new()

export var sounds = [""]

func process(context, delta):
	pass

func start(action, context):
	rng.randomize()
	pass
	
func on_state_changed(action, context):
	pass

func execute_impl(action, context):
	var actor = context._entity2node[action.entity.id]
	
	#choose random sound
	var rnd_idx = rng.randi_range(0, len(sounds)-1)
	
	if actor.has_node("FX"):
		actor.get_node("FX").get_node(sounds[rnd_idx]).play()
