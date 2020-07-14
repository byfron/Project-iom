extends Node2D

onready var sprite = $Sprite
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func aim_mode():
	sprite.frame = 1

func select_mode():
	sprite.frame = 0

