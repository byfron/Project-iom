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
		var offset = (0.95*position + 0.05*player_pos) - position
		position += offset
		
		
		#camera position is always centered!
		
		
		
		#we need to pass the camera position to the reflection shaders
		#to account for camera motion
#		var tilemap = get_parent().world_map.tilemap_controller.water_reflections.tilemap
#		var tileset = tilemap.get_tileset()
#		var material = tileset.tile_get_material(0)
#		tileset.tile_get_material(0).set_shader_param('camera_offset', offset)
#		tileset.tile_get_material(1).set_shader_param('camera_offset', offset)
#
#		tileset.tile_get_material(0).set_shader_param('camera_offset', offset)
	
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
