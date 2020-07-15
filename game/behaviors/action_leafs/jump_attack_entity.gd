extends "res://addons/godot-behavior-tree-plugin/action.gd"
var ActionFactory = load('res://game/core/ActionFactory.gd').new()
# Leaf Node
func tick(tick: Tick) -> int:
	return FAILED
	
	var context = tick.blackboard.get('context')
	var actor = tick.actor
	var entity = EntityPool.get(actor.entity_id)
	var actor_tile = Utils.get_entity_location(entity)
	
	#TODO: if the entity is airborn we can't attack it
	var attacked_node = context.get_player_node()
	#if attacked_node.airborn == true:
	#	return FAILED
	
	var player_location = Utils.get_entity_location(EntityPool.get(context.player_entity_id))
	#compute the tile path straight trajectory and save it in the jump action
	var tiles = Utils.get_line_coords(actor_tile, player_location)
	#Let's say that over 3 tiles we prefer melee
	if len(tiles) <= 3:
		return FAILED

	var action = ActionFactory.create_jump_attack_action(EntityPool.get(actor.entity_id), tiles)
	SignalManager.emit_signal('send_action', action)
	return OK
