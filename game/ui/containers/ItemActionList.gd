extends MarginContainer
onready var action_container = $MarginContainer/MarginContainer/VBoxContainer
var ActionNode = preload("res://game/ui/containers/Action.tscn")

func _ready():
	pass 

func clear_actions():
	for n in action_container.get_children():
		action_container.remove_child(n)
		n.queue_free()
		
	#put width/height back to zero
	rect_size.x = 0
	rect_size.y = 0

func show_entity_actions(entity):
	show()
	clear_actions()
	rect_position = get_viewport().get_mouse_position() - Vector2(5,5)
	var actions = EntityPool.get_actions(entity)
	for action in actions:
		var action_node = ActionNode.instance()
		action_node.action_text = action[1]
		action_node.action_id = action[0]
		action_container.add_child(action_node)

func _on_ActionSelector_mouse_exited():
	#Mouse_exited gets trigger when hovering over children, so we brute-force check here
	#that the mouse has truly existed the control rect
	var mouse_is_inside = get_global_rect().has_point(get_global_mouse_position())
	if not mouse_is_inside:
		hide()
