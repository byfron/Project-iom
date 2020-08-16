extends CanvasModulate

var world_scene = null

func _ready():
	pass
	#$Label.color = Color(1.0, 1.0, 1.0, 0.0)

############################ Experiment###########################################3
#TODO: this should be somewhere else, 
#maybe inside an action that is processed by the weather_system
func start_rain():
	$WeatherTween.interpolate_property(self, "color", color, Color(0.290196, 0.270588, 0.45098), 5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$WeatherTween.start()
	
func _on_WeatherTween_tween_completed(object, key):
	var rain_node = load('res://game/fx/Rain.tscn').instance()
	world_scene.camera.add_child(rain_node)
	
################################ Experiment###########################################3

func fade_to_black():
	var label = world_scene.gui_layer.get_node("YouDiedLabel")
	$ColorTween.interpolate_property(self, "color", color, Color(0.15, 0.15, 0.15), 5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ColorTween.interpolate_property(label, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$ColorTween.start()
