extends Node2D

#onready var body_panel = $GridContainer/MarginContainer/VBoxContainer/BodyParts
#onready var item_info_panel = $GridContainer/MarginContainerItemInfo/ItemInfoPanel

var action_button_map = {}
onready var acontainer = $ActionContainer2

# Called when the node enters the scene tree for the first time.
func _ready():
	#SignalManager.connect("inventory_show_item_info", self, "show_item_info")
	#SignalManager.connect("stopped_hovering_item", self, "start_hidepanel_timer")
	#SignalManager.connect("mouse_out_of_gui", item_info_panel, "hide")
	
	acontainer = get_node("ActionContainer2")

	#Create a map with all the actions
	for button in acontainer.get_children():
		var action_id = button.action_type
		action_button_map[action_id] = button

	

	SignalManager.connect("highlight_action_button", self, "highlight_action_button")
#func update():
#	var entity = GameEngine.context.get_player_entity()
#	var inventory = entity.components['inventory']
#	#var inventory_panel = get_inventory()
#
#	#TODO: refactor this to inventory!
#	inventory_panel.clear_inventory()
#	for ent_id in inventory.get_stored_entities():
#		inventory_panel.add_item(ent_id)
#
#	var weilded_weapon = inventory.get_weilded_in_main_hand()
#	if weilded_weapon:
#		inventory_panel.add_tag(weilded_weapon, "(equipped - main)")

#func show_item_info(entity_id):
#	var item_info_timer = $GridContainer/MarginContainerItemInfo/ItemInfoTimer
#	item_info_timer.stop()
#
#	#item_info_panel.show()
#
#	#assign container entity (selected entity)
#	#TODO: this is kind of ugly. Maybe pass the container in the signal
#	var container = GameEngine.context.get_player_entity()
#	item_info_panel.show_entity(entity_id, container)
	
#func get_inventory():
#	return $GridContainer/TabContainer/TabContainer/Inv

#func _on_TextureButton_toggled(button_pressed):
#	if button_pressed:
#		body_panel.show()
#	else:
#		body_panel.hide()
#
#	$GridContainer/MarginContainer.rect_size.y = 0

#func update_health(health):
#	var health_bar = $GridContainer/MarginContainer/VBoxContainer/HealthBar
#	health_bar.value = health
#	health_bar.refresh()
	
func highlight_action_button(action_id):
	action_button_map[action_id].highlight()
	pass

#func start_hidepanel_timer():
#	var item_info_timer = $GridContainer/MarginContainerItemInfo/ItemInfoTimer
#	item_info_timer.start()
#
#func _on_ItemInfoTimer_timeout():
#	item_info_panel.hide()
#
#func _on_ItemInfoPanel_mouse_entered():
#	var item_info_timer = $GridContainer/MarginContainerItemInfo/ItemInfoTimer
#	item_info_timer.stop()
