extends "res://game/behaviors/trees/abstract_behavior.gd"

func init_behavior(actor, context):
	.init_behavior(actor, context)
	var blackboard = $BehaviorBlackboard
	blackboard.set('memory', actor.memory)
