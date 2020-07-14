extends Node2D
onready var item_container = $PanelContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer
onready var action_list = $ActionListNode

func _ready():
	SignalManager.connect("update_inventory", self, "update_inventory")
	pass
	
func fill_with_inventory(inventory):
	Utils.delete_children(item_container)
	var idx = 0
	for ent_id in inventory.get_stored_entities():
		var entity = EntityPool.get(ent_id)
		var entry = create_inventory_entry(entity)
		if idx%2 == 0:
			entry.set_color(Color(0.372549, 0.321569, 0.188235))
		else:
			entry.set_color(Color(0.0,0.0,0.0,0.0))
		idx += 1

func update_inventory():
	var player_entity = GameEngine.context.get_player_entity()
	fill_with_inventory(player_entity.components["inventory"])

func create_inventory_entry(entity):
	var inventory_entry = load("res://game/ui/containers/InventoryEntry.tscn").instance()
	inventory_entry.set_item_name(entity.name)
	inventory_entry.item_entity = entity
	item_container.add_child(inventory_entry)
	return inventory_entry

func _on_MarginContainer_gui_input(event):
	if (event is InputEventMouseButton && event.pressed):
		hide()
