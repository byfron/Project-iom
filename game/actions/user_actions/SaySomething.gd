extends "UserAction.gd"

var dialog = ""

func start_impl(context):
	#pass
	var node = get_map_node(context)
	#Check input code in table to see what shall we say

	node.say_stuff(dialog, 3.0)#time)
		
func execute_impl(action, context):
	pass
	
	
