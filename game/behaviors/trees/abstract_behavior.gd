extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init_behavior(context):
	var blackboard = $BehaviorBlackboard
	blackboard.set('context', context)
	blackboard.set("enemy_list", [])
	
func onEvent(etype, entity_id):
	var blackboard = $BehaviorBlackboard
	#TODO: enum of events for behavior trees
	#TODO: we could also be listening to signals to do broadcast events
	if etype == "attacked":
		var enemy_list = blackboard.get('enemy_list')
		enemy_list.append(entity_id)
		blackboard.set('enemy_list', enemy_list)
		
	pass
