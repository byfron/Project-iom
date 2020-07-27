extends Node2D

var entity_name = null;
var entity_id = null;
var actions = []
var coords = null
var entity_type = null
var is_obstacle = false

export(Texture) var image setget set_image
export(Texture) var normal_map setget set_normal_map
export(Color) var color setget set_color

onready var sprite_sheet = $Sprite

func set_color(col):
	color = col
	if Engine.editor_hint:
		var base = $base
		base.self_modulate = color
	
func set_image(im):
	image = im
	if Engine.editor_hint:
		var sprite = $Sprite
		sprite.texture = image
		var shadow = $Shadow
		shadow.texture = image

func set_normal_map(im):
	normal_map = im
	if Engine.editor_hint:
		var sprite = $Sprite
		sprite.normal_map = image

func _ready():
#	$Sprite.texture = image
#	$Shadow.texture = image
	
	#TODO: refactor actor
	$AttackedTimer.connect("timeout", self, "attacked_timer_ended")
	$AttackedTimer.wait_time = GameEngine.MAX_TURN_TIME
	
	pass

func select(flag):
	var sprite = $Sprite
	var mat = sprite.get_material().duplicate()
	mat.set_shader_param("selected", flag)
	sprite.material = mat
	
func move_sprite_to_correct_location(volume = null):
	var rect_size = $Sprite.region_rect.size
	if not volume:
		$Sprite.position.y = -(rect_size.y/2)
		$Sprite.position.x = -(rect_size.x/2 - 16)
		$Shadow.position.x = -(rect_size.x/2 - 16)
		
		#Move shadow slightly up
		$Shadow.position.y = -rect_size.y/2
	else:
		$Sprite.position.y = -rect_size.y + 32
		$Sprite.position.x = 0

##TODO: Refactor ACtor/OBject scenes and create an inheritance!
func orientCharacterTowards(o):
	pass
	
func take_melee_damage(damage):
	pass
	#explode()
	#pass
	
func explode():
	#We have the sprite as a region rect. We'll have to create 
	#as many new rects as particles in the explosion
	#load('res://game/actors/FX/ShatteredSprite.tscn')
	var explosion = load('res://game/actors/FX/Explosion.tscn').instance()
	#explosion.img()
	
	explosion.initialize($Sprite.texture, $Sprite.region_rect, 5, 5)
	explosion.detonate = true
	
	#remove sprite and add explosion
	$Sprite.hide()
	$Shadow.hide()
	add_child(explosion)
	
	#TODO: delete object
	

##TODO: Refactor ACtor/OBject scenes and create an inheritance!
func attacked(flag):
	#set up a timer to bring this back to normal
	var mat = $Sprite.get_material().duplicate()
	mat.set_shader_param("attacked", flag)
	$Sprite.material = mat
	$AttackedTimer.start()

func attacked_timer_ended():
	var mat = $Sprite.get_material().duplicate()
	mat.set_shader_param("attacked", false)
	$Sprite.material = mat

func set_graphics(gid, gtype, cast_shadows=true, direction=null):
	#load graphics dor all states
	var sprite_sheet = $Sprite
	var shadow_sheet = $Shadow
		
		
	if not cast_shadows:
		shadow_sheet.hide()
		
	#We identity the object as the id + orientation (if it has any!)
	#This is a bit ugly as it couples graphic generation and ECS, but fuck it
	var object_gid = str(gid)
	if direction:
		object_gid += direction
		
	if object_gid in ResourceManager._object_sprite_meta:
		var texture = ResourceManager._object_sprite_meta[object_gid]['texture']
		sprite_sheet.texture = load('res://game_assets/textures/objects/DIFFUSE_' + texture)
		sprite_sheet.normal_map = load('res://game_assets/textures/objects/NORMAL_' + texture)
		shadow_sheet.texture = sprite_sheet.texture
		var atlas_coords = ResourceManager._object_sprite_meta[object_gid]['coords']
		var sprite_size = ResourceManager._object_sprite_meta[object_gid]['size']
		sprite_sheet.region_rect.position = Vector2(atlas_coords[1]*sprite_size[0], atlas_coords[0]*sprite_size[1])
		sprite_sheet.region_rect.size = Vector2(sprite_size[0], sprite_size[1])
		shadow_sheet.region_rect.position = Vector2(atlas_coords[1]*sprite_size[0], atlas_coords[0]*sprite_size[1])
		shadow_sheet.region_rect.size = Vector2(sprite_size[0], sprite_size[1])
	
		#adjust position acoording to asset size
		#position.x = 16 * (sprite_size[0]/32)
	
	#frames = load(ResourceManager.get_sprite_sheet(gid)).duplicate()
	
	pass
	
func create_light(lid):
	if lid == 0:
		var lnode = load('res://game/actors/lights/LampLight.tscn').instance()
		$Light.add_child(lnode)
	elif lid == 1:
		var lnode = load('res://game/actors/lights/spot_light.tscn').instance()
		$Light.add_child(lnode)
	elif lid == 2:
		var lnode = load('res://game/actors/lights/window_light.tscn').instance()
		$Light.add_child(lnode)
	
	
	$Light.show()
	
func update():
	var entity = EntityPool.get(entity_id)
	var gid = entity.components['graphics'].get_graphics_id()
	var gtype = entity.components['graphics'].get_gtype()
	set_graphics(gid, gtype)
	
	
	
	pass
