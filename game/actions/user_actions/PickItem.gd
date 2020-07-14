extends "UserAction.gd"

var item_entity = null
var container_entity = null

func execute_impl(action, context):
	InventoryUtils.add_item_to_inventory(action.entity.components['inventory'], action.item_entity.id)
	SignalManager.emit_signal("update_inventory")
	
	if container_entity:
		Utils.remove_entity_from_container(container_entity, action.item_entity)
	else:
		Utils.remove_entity_from_ground(action.item_entity)
