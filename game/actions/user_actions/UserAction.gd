extends "res://game/actions/Action.gd"

var key_shortcut = ""
var description = ""
var roll_text = ""
var validity_info = ""
var success_rate = 0
var signal_on_touch = null
var is_valid = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_action(action_info, entity):
	.init(entity)
	#description = action_info.get_description()
	#action_name = action_info.get_name()
	#priority = action_info.get_priority()
	#execution_state = action_info.get_execute()
