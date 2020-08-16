extends Sprite

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1,1), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
