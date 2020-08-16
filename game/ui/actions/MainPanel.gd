extends Node2D

var action_button_map = {}
var _hightlighted_button = null

func _ready():
	var action_container = $MainActionContainer
	var weapon_actions = $WeaponActionContainer
	for button in action_container.get_children() + weapon_actions.get_children():
		var action_id = button.action_type
		action_button_map[action_id] = button
	
	SignalManager.connect("highlight_action_button", self, "highlight_action_button")
	SignalManager.connect("unhighlight_all_buttons", self, "unhighlight_all_buttons")
	SignalManager.connect("update_health", self, "update_health_bar")
	SignalManager.connect("update_stamina", self, "update_stamina_bar")
	
	SignalManager.connect("action_button_pressed", self, "action_button_pressed")

func action_button_pressed(action_id):
	highlight_action_button(action_id)

func highlight_action_button(action_id):
	if _hightlighted_button:
		_hightlighted_button.unhighlight()
		
	action_button_map[action_id].highlight()
	_hightlighted_button = action_button_map[action_id]
	
func unhighlight_all_buttons():
	for aid in action_button_map:
		action_button_map[aid].unhighlight()
		
func update_health_bar(health):
	$HealthBar.set_bar_value(health)
	$HealthBar.refresh()
	pass
	
func update_stamina_bar(stamina):
	$StaminaBar.set_bar_value(stamina)
	$StaminaBar.refresh()
	pass

func _on_InventoryButton_gui_input(event):
	if (event is InputEventMouseButton && event.pressed):
		GameEngine.context.world.show_inventory()

func _on_CheckButton_toggled(button_pressed):
	GameEngine.set_debug_mode(button_pressed)

