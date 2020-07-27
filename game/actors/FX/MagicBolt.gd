extends Node2D

var num_frames = 5
var total_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func set_animation(delta_time):
	var anim = $AnimatedSprite
	#var frame_time = 1.0/5
	
	#print('delta:', delta_time)
	#print('FRAME', int(5 * delta_time))
	
	anim.frame = int(delta_time * num_frames) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func explode():
	$Particles2D.emitting = true
	$AnimatedSprite.hide()
	$AnimatedSprite.hide()
