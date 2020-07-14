extends Node2D

var ItemProperty = load("res://game/ui/panels/ItemProperty.tscn")

onready var item_name_label = $GridContainer/MarginContainer/MarginContainer/VBoxContainer/HeaderBox/Name
onready var item_category_label = $GridContainer/MarginContainer/MarginContainer/VBoxContainer/HeaderBox/Category
onready var item_desc = $GridContainer/MarginContainer/MarginContainer/VBoxContainer/DescriptionContainer/Description
onready var property_container = $GridContainer/MarginContainer/MarginContainer/VBoxContainer/GridContainer
onready var action_panel_container = $GridContainer/MarginContainer/MarginContainer/VBoxContainer/ActionPanelContainer
onready var container_panel = $GridContainer/ContainerPanel
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _container_entity = null

var idx = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	idx += 1
	#SignalManager.connect("infopanel_show_item_info", self, "show_item_info")
	#SignalManager.connect("mouse_out_of_gui", self, "hide_item_info")

func clear_properties():
	for n in property_container.get_children():
		property_container.remove_child(n)
		n.queue_free()

func display_entity(entity):
	show_item(entity.id)

func hide_entity(entity):
	hide()

#Gets currently selected/highlighted entity and displays all info
#func update():
#	var selected_entity = GameEngine.context.get_selected_entity()
#	if selected_entity:
#		if GameEngine.context.entity_is_highlighted():
#			#TODO: we can refactor this calls as Utils.is_a_container(selected_entity)
#			if 'container' in selected_entity.components:
#				update_container_info(selected_entity)
#
#
#func update_container_info(entity):
#	var contained_entities = entity.components["container"].get_entities()
#	set_container_items(contained_entities)
#	show_container(entity)
	
#func hide_entity_actions(entity):
#	$GridContainer/MarginContainer/MarginContainer/VBoxContainer/DescriptionContainer.hide()
#	Utils.delete_children(action_panel_container)

#func compute_action_entry(action):
#	var aentry = ActionInfoEntry.instance()
#	var short_cut = ActionManager.get_action_shortcut(action)
#	var action_color = Color(1,0,1,1)
#	aentry.create_action_instance(action, short_cut, action_color)	
#	aentry.set_enabled(action.is_valid)
#	return aentry

#func get_current_action_panels():
#	var action_panels = []
#	for action_type in ActionManager.action_map:
#		var subpanel = ActionSubPanel.instance()
#		subpanel.set_title(action_type)
#		for action in ActionManager.action_map[action_type]:
#			var action_entry = compute_action_entry(action)
#			subpanel.call_deferred("add_entry", action_entry)
#
#		action_panels.append(subpanel)
#	return action_panels

#func display_entity_actions(entity):
#	$GridContainer/MarginContainer/MarginContainer/VBoxContainer/DescriptionContainer.show()
#	Utils.delete_children(action_panel_container)
#	var action_panels = get_current_action_panels()
#	for actionp in action_panels:
#		action_panel_container.add_child(actionp)
		
func show_item(entity_id):
	var entity = EntityPool.get(entity_id)
	
	clear_properties()
	
	self.visible = true
	item_name_label.text = entity.name
	if 'description' in entity.components:
		item_desc.text = entity.components['description'].get_description()
	
	
	#ITEMS are NEVER visualized in the first panel. Only stuff that are elements of the map. 
	#Doors, containers, tile, characters, etc... 
	#If such entity contains entities then the list is displayed and can be interacted with. 
	#how?
	# going through them shows the additional info in a window adjacent to the list. 
	# Mouse can move to it and click the available actions "pick, drop, etc..."
		
	if 'character' in entity.components:
		item_category_label.text = 'character'
		
#	if 'container' in entity.components:
#		#display the container panel as well!
#		var container = $GridContainer/ContainerPanel
#		container.show()
		

#func hide_panel():
#	self.visible = false
#	hide_container()
#
#func set_container_items(items):
#	container_panel.set_items(items)

#func show_container(container_entity):
#	container_panel.show()
#	_container_entity = container_entity
#
#func hide_container():
#	container_panel.hide()
#	hide_item_info()

#func show_item_info(entity_id):
#	$GridContainer/ItemInfoDummyContainer.hide()
#	$GridContainer/ItemInfoPanel.show()
#
#	#assign container entity (selected entity)
#	#TODO: this is kind of ugly. Maybe pass the container in the signal
#	$GridContainer/ItemInfoPanel.show_entity(entity_id, _container_entity)
#
#func hide_item_info():
#	$GridContainer/ItemInfoDummyContainer.show()
#	$GridContainer/ItemInfoPanel.hide()

func _on_TextureButton_pressed():
	GameEngine._fsm.emit('cancel_mode')
	#cancel current mode
