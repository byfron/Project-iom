extends Camera2D

var player_actor = null
var shake_period = 0.2
var shake_scale = 10
var shake_camera = false
var time = 0

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_actor:
		var player_pos = Utils.getScreenCoordsTileCenter(player_actor.coords)
		position = 0.95*position + 0.05*player_pos
	
	if shake_camera:
		if time < shake_period:
			time += delta
			var offset = Vector2()
			offset.x = rand_range(-shake_period, shake_period)
			offset.y = rand_range(-shake_period, shake_period)
			position += offset * shake_scale
		else:
			shake_camera = false

func moveTo(pos):
	return

func shakeCamera():
	time = 0
	shake_camera = true
