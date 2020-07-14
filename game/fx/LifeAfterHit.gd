extends Node2D

export(String) var life_text = '' setget set_life_text
onready var post_main_label = $Post/CenterContainer/Label
onready var post_sub_label1 = $Post/CenterContainer/LabelBorder
onready var post_sub_label2 = $Post/CenterContainer/LabelBorder2
onready var pre_main_label = $Pre/CenterContainer/Label

func set_life_text(text):
	life_text = text
	post_main_label.text = life_text
	post_sub_label1.text = life_text
	post_sub_label2.text = life_text
	pre_main_label.text = life_text
	
func _ready():
	$PreTimer.connect("timeout", self, "start_post")
	$PostTimer.connect("timeout", self, "fade_out")
	$FadeOutTween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), .8, Tween.TRANS_SINE, Tween.EASE_OUT)

func start(damage):
	$FadeOutTween.stop_all()
	$PostTimer.stop()
	$PreTimer.stop()
	show()
	set_life_text(str(damage))
	$Pre.show()
	$PreTimer.start()

func start_post():
	$Pre.hide()
	$Post.show()
	$PostTimer.start()

func fade_out():
	$FadeOutTween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), .8, Tween.TRANS_SINE, Tween.EASE_OUT)
	$FadeOutTween.start()

func _on_FadeOutTween_tween_completed(object, key):
	$Post.hide()
	hide()
	modulate = Color(1,1,1,1)
