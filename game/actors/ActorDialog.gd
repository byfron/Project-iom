extends Node2D

export var dialog_text = ''# setget say_stuff

onready var text_label = $DialogLabel/Label
onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func randomize_location(rect_size_x):
	var y_range = rand_range(-50, -100)
	var x_range = rand_range(-100 - rect_size_x, 100 - rect_size_x)
	var label_node = $DialogLabel
	#var text_label = $DialogLabel/Label
	label_node.position = Vector2(x_range, y_range)
	print("LABEL RECT:", Vector2(x_range, y_range))
	#print("LABEL RECT:", text_label.rect_position)

func say_stuff(text, time):
	show()
	dialog_text = text
	var text_label = $DialogLabel/Label
	text_label.text = text
	text_label.rect_size.x = 0
	
	var size = text_label.get_combined_minimum_size()
	randomize_location(text_label.rect_size.x)
	var label_node = $DialogLabel
	var mid_pos = label_node.position + Vector2(size.x/2, size.y)
	
	var line = $Line2D
	line.points[1] = mid_pos
	line.points[0] = Vector2(0,0)
	
	$Timer.wait_time = time
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Timer_timeout():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), .8, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()


func _on_Tween_tween_all_completed():
	self.modulate = Color(1,1,1,1)
	hide()
	pass # Replace with function body.
