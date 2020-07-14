extends Node2D
onready var item_container = $PanelContainer/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer
var container_entity = null

func _ready():
	pass

func fill_with_container(container_entity):
	#get entities from container
	var container = container_entity.components['container']
	Utils.delete_children(item_container)
	var entity_ids = container.get_entities()
	for ent_id in entity_ids:
		var entity = EntityPool.get(ent_id)
		var entry = load('res://game/ui/containers/ItemEntry.tscn').instance()
		entry.item_name = entity.name
		entry.item_entity = entity
		entry.container_entity = container_entity
		item_container.add_child(entry)
	
func _on_MarginContainer_gui_input(event):
	if (event is InputEventMouseButton && event.pressed):
		hide()
