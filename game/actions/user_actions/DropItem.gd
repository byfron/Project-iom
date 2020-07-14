extends "UserAction.gd"

var item_entity = null

func execute_impl(action, context):
	InventoryUtils.remove_item_from_inventory(action.entity.components['inventory'], action.item_entity.id)
	SignalManager.emit_signal("update_inventory")
	var tile = context.get_player_node().coords
	#Add location component to the item entity
	Utils.add_entity_location(item_entity, tile)
	
	#if there's a item entity, we create an item, otherwise we get the node and add it
	#TODO: theoretically only one item(node) can be in a tile
	var nodes = context.get_item_nodes_in_tile(tile)
	if nodes:
		nodes[0].add_item_entity(item_entity)
	else:
		context.create_ground_item(item_entity, tile)
	
