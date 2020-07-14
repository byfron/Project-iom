tool
extends PanelContainer
var ActionFactory = load("res://game/core/ActionFactory.gd").new()
onready var label = $MarginContainer/Label
var action = null

#if the action involves a "third" entity, for instance, when taking an item from a 
#container, we pass also the entity to create the action
var third_entity = null

export(String) var action_text setget set_text

func set_text(t):
	action_text = t
	if Engine.editor_hint:
		var label = $MarginContainer/Label
		label.text = t
		
func _ready():
	label.text = action_text

func _on_Action_mouse_entered():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color(0.08,0.42,0.2,1.0))
	set('custom_styles/panel', style)

func _on_Action_mouse_exited():
	var style = StyleBoxFlat.new()
	style.set_bg_color(Color(0,0,0,0))
	set('custom_styles/panel', style)

func _on_Action_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		SignalManager.emit_signal('send_action', action)
		SignalManager.emit_signal("hide_inventory")
		
