extends "UserAction.gd"

var item_entity = null

func execute_impl(action, context):
	#add item in the "right hand wielded" slot
	var inventory = action.entity.components['inventory']
	inventory.set_weilded_in_main_hand(item_entity.id)
	
	var node = action.get_map_node(context)
	node.initialize_char_object_animations()
	
	
	#TODO: update weapons skill button images
