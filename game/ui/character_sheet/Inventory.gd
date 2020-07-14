extends MarginContainer

var ItemInfoEntry = load("res://game/ui/panels/info_panel/ItemInfoEntry.tscn")
onready var container = $ScrollContainer/VBoxContainer

func clear_inventory():
	Utils.delete_children(container)

func remove_item(item_ent_id):
	for child in container.get_children():
		if child.entity_id == item_ent_id:
			container.remove_child(child)

func add_tag(item_ent_id, tag):
	for item_entry in container.get_children():
		if item_entry.entity_id == item_ent_id:
			item_entry.set_tag(tag)

func add_item(item_ent_id):
	var item_ent = EntityPool.get(item_ent_id)
	var item_entry = ItemInfoEntry.instance()
	item_entry.item_name  = item_ent.name
	item_entry.entity_id = item_ent_id
	item_entry.hover_signal = "inventory_show_item_info"
	container.add_child(item_entry)

func set_items(item_entity_ids):
	Utils.delete_children(container)
	for ent_id in item_entity_ids:
		add_item(ent_id)
