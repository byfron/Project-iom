extends Node
var ActionFactory = preload('res://game/core/ActionFactory.gd').new()
const ActionTypes = preload("res://game/actions/ActionTypes.gd").ActionType
var action_map = {}

#The ActionManager needs to keep track of the available actions at the moment
#and if they are valid. Should listen to a signal update_action_map in case anything changes.
#For instance, a position change should update the action map because a weapon may not reach
#anymore

func get_default_action():
	pass

func get_action_shortcut(action):
	var input_list = InputMap.get_action_list(action.action_name)
	if len(input_list) > 0:
		var kevent = input_list[0]
		var text = kevent.as_text()
		return kevent.as_text()
	
	return ''
