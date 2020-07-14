extends "UserAction.gd"

func _ready():
	pass

func execute_impl(action, context):
	#Change status of entity
	action.entity.components['char_status'].set_crouching(true)
