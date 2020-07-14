extends "UserAction.gd"

var item_entity = null

func execute_impl(action, context):
	#add item in the "right hand wielded" slot
	var inventory = action.entity.components['inventory']
	inventory.set_weilded_in_main_hand(item_entity.id)
