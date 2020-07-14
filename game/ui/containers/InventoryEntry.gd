extends PanelContainer
tool

var item_entity = null

export var item_name = '' setget set_item_name
export(Color) var color = null setget set_color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_color(col):
	color = col
	var new_style = get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	set("custom_styles/panel", new_style)
	
func set_item_name(name):
	item_name = name
	$MarginContainer/MainHBox/HBoxContainer/Name.text = name


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Control_gui_input(event):
	if (event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_RIGHT):
	#	inventory_container.action_list.global_position = inventory_container.get_global_mouse_position()
		#inventory_container.action_list.show()
		SignalManager.emit_signal("item_selected", item_entity)
		#var actions = ActionFactory.get_item_actions(event)


func _on_Control_mouse_exited():
	pass
	#inventory_container.action_list.hide()
