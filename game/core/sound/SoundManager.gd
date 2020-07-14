extends Node

onready var audio_stream = $TestAudio
var _sound_map = []

func play_sound(tag):
	audio_stream.play()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
