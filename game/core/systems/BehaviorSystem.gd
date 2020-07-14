extends Node

func update(context, entity):
	
	#TODO: maybe we can add a system method that filters the entities?
	if not 'behavior' in entity.components:
		return
	
	# Check first if there's anything to react to. For instance:
	# When the entity is attacked, we mark that node as an "enemy" and decide what to do:
	# We can send a signal to an entity using his name, and that's an event. For instance being hit, etc...
	# behaviortrees are listening to the entity.id signal

	var btree = context.behavior_map[entity.id].get_node('BehaviorTree')
	var blackboard = context.behavior_map[entity.id].get_node('BehaviorBlackboard')
	
	if blackboard == null:
		pass
	
	
	#only continue the behavior if there are no actions pending
	var action = context.action_queue.get(entity.id)
	if action == null:
		var actor = context._entity2node[entity.id]
		btree.tick(actor, blackboard)
