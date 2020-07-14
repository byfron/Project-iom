extends Node2D

var action_button_map = {}

func _ready():
	var action_container = $MainActionContainer
	for button in action_container.get_children():
		var action_id = button.action_type
		action_button_map[action_id] = button
	
	SignalManager.connect("highlight_action_button", self, "highlight_action_button")
	SignalManager.connect("unhighlight_all_buttons", self, "unhighlight_all_buttons")

func highlight_action_button(action_id):
	action_button_map[action_id].highlight()
	
func unhighlight_all_buttons():
	for aid in action_button_map:
		action_button_map[aid].unhighlight()

func _on_InventoryButton_gui_input(event):
	if (event is InputEventMouseButton && event.pressed):
		GameEngine.context.world.show_inventory()
