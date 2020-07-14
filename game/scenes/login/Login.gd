extends Node2D

onready var login_button = $Button
var _network_controller = null

func _ready():
	pass

func _enter_tree():
	_network_controller.connect("client_connected", self, "_on_connected")

func _on_connected():
	var login_msg = Message.LoginMsg.new("johnny")
	_network_controller.send_data(login_msg.get_msg())
	
func _on_Button_button_down():
	_network_controller.connect_to_server()
