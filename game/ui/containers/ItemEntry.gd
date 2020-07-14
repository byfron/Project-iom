extends PanelContainer
tool

var item_entity = null
var container_entity = null

export var item_name = '' setget set_item_name

func set_item_name(name):
	item_name = name
	$MarginContainer/MainHBox/HBoxContainer/Name.text = name

func _ready():
	pass

func _on_TextureButton_pressed():
	#Send signal to pick up the entity
	var pentity = GameEngine.context.get_player_entity()
	var action = ActionFactory.create_pick_item_action(pentity, container_entity, item_entity)
	SignalManager.emit_signal("send_action", action)
	
	#remove item from list
	get_parent().remove_child(self)

	#close inventory
	
	
