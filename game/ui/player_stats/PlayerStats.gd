extends Node2D

onready var life_bar = $LifeBar

func increase_life(v):
	life_bar.increase_by(v)
	
func decrease_life(v):
	life_bar.decrease_by(v)
	
	
