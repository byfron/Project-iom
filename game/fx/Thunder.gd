extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start_thunder():
	$Tween.interpolate_property($ColorRect, "color", Color(1,1,1,.3), Color(1,1,1,0), 1.2, Tween.EASE_IN, Tween.EASE_OUT)
	$Tween.start()
	$ThunderSound.play()
	
func _on_Timer_timeout():
	
	#Set a new random wait time on the timer 
	$Timer.wait_time = randi()%20 + 10
	
	start_thunder()
	
	
