extends "res://addons/godot-behavior-tree-plugin/action.gd"
var ActionFactory = load('res://game/core/ActionFactory.gd').new()
# Leaf Node
func tick(tick: Tick) -> int:
	return OK
	var context = tick.blackboard.get('context')
	var actor = tick.actor
	
	#TODO: if the entity is airborn we can't attack it
	var attacked_node = context.get_player_node()
	#if attacked_node.airborn == true:
	#	return FAILED
	
	var player_location = Utils.get_entity_location(EntityPool.get(context.player_entity_id))
	var action = ActionFactory.create_melee_attack_action(EntityPool.get(actor.entity_id), player_location)
	SignalManager.emit_signal('send_action', action)
	return OK
