extends "UserAction.gd"

func execute_impl(action, context):
	action.entity.components['char_status'].set_crouching(false)

