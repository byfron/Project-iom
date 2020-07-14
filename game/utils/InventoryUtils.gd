extends Node

func remove_item_from_inventory(inventory, item_id):
	inventory._stored_entities.value.erase(item_id)

func add_item_to_inventory(inventory, item_id):
	#TODO: check for encumbered?
	inventory._stored_entities.value.append(item_id)
