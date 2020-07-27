extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$RainSoundTween.interpolate_property($RainSound, "volume_db", -80, 0, 4,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	$RainSoundTween.start()
	
	#TODO: REMOVE THIS TEMP. CODE
	var timer = Timer.new()
	timer.wait_time = 6
	timer.one_shot = true
	timer.connect("timeout", self, "trigger_say_stuff")
	add_child(timer) 
	timer.start()
	
func trigger_say_stuff():
	GameEngine.context.get_player_node().say_stuff("Oh crap!. This is going to ruin my shoes", 3)

