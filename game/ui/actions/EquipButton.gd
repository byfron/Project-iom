extends Control
tool

enum Test {TA=0, TB}

const ActionTypes = preload("res://game/actions/ActionTypes.gd")

export(Texture) var image setget assign_image
export(ActionTypes.ActionType) var action_type = ActionTypes.ActionType.LOOK
export(Color) var color setget set_color
onready var clip_panel = $ItemContainer/ClipPanel
onready var clip_panel_tween = $ItemContainer/ClipPanelTween

var _activated = false

func set_color(col):
	color = col
	if Engine.editor_hint:
		var new_style = $MarginContainer/Panel.get_stylebox("panel").duplicate()
		new_style.set_bg_color(color)
		$MarginContainer/Panel.set("custom_styles/panel", new_style)

func assign_image(im):
	image = im
	$MarginContainer/MarginContainer/Icon.texture = im

func _ready():
	var new_style = $MarginContainer/Panel.get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	$MarginContainer/Panel.set("custom_styles/panel", new_style)
	
	clip_panel.rect_position.y = -10
	clip_panel.rect_size.y = 0
	
func highlight():
	$Highlight.show()

func unhighlight():
	$Highlight.hide()

func _on_Control_mouse_entered():
	pass # Replace with function body.

func create_weapon_button(we):
	var wb = load('res://game/ui/actions/WeaponButton.tscn').instance()
	var itype = we.components['item'].get_itype()
	wb.image = load(ResourceManager.get_item_icon_sprite(itype)).duplicate()
	wb.weapon_entity = we
	wb.set_weapon_name(we.name)
	$ItemContainer/ClipPanel/VBoxContainer.add_child(wb)

func activate():
	
	Utils.delete_children($ItemContainer/ClipPanel/VBoxContainer)
	
	var player_weapons = Utils.get_player_weapons()
	for weapon in player_weapons:
		create_weapon_button(weapon)

	yield(get_tree(), "idle_frame")

	_activated = true
	#get size of vboxcontainer 
	var ysize = $ItemContainer/ClipPanel/VBoxContainer.rect_size.y
	
	var speed = len(player_weapons) * 0.05
	
	var new_pos = clip_panel.rect_position
	new_pos.y = -ysize - 10
	var new_size = clip_panel.rect_size
	new_size.y = ysize
	
	clip_panel_tween.interpolate_property(clip_panel, "rect_position", 
	clip_panel.rect_position, new_pos, speed,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	clip_panel_tween.interpolate_property(clip_panel, "rect_size", 
	clip_panel.rect_size, new_size, speed,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	
	clip_panel_tween.start()

func deactivate():
	
	_activated = false
	
	var num_weapons = $ItemContainer/ClipPanel/VBoxContainer.get_child_count()
	var speed = num_weapons * 0.05
	
	#get size of vboxcontainer 
	var ysize = $ItemContainer/ClipPanel/VBoxContainer.rect_size.y
	
	var new_pos = clip_panel.rect_position
	new_pos.y = -10
	var new_size = clip_panel.rect_size
	new_size.y = 0
	
	clip_panel_tween.interpolate_property(clip_panel, "rect_position", 
	clip_panel.rect_position, new_pos, speed,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	clip_panel_tween.interpolate_property(clip_panel, "rect_size", 
	clip_panel.rect_size, new_size, speed,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	
	clip_panel_tween.start()

func _on_Control_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && event.button_index == BUTTON_LEFT:
			if not _activated:
				activate()
			else:
				deactivate()
				
			#SignalManager.emit_signal('action_button_pressed', action_type)
