extends "ActionButton.gd"
tool

export var weapon_name = '' setget set_weapon_name
var weapon_entity = null

func set_weapon_name(wn):
	weapon_name = wn
	$Node2D/Label.text = weapon_name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT:
			var pentity = GameEngine.context.get_player_entity()
			var action = ActionFactory.create_equip_action(pentity, weapon_entity)
			SignalManager.emit_signal('send_action', action)
