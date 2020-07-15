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
	$Sprite.texture = image
	$Shadow.texture = image
	
	#TODO: refactor actor
	$AttackedTimer.connect("timeout", self, "attacked_timer_ended")
	$AttackedTimer.wait_time = GameEngine.MAX_TURN_TIME
	
	pass

func select(flag):
	var sprite = $Sprite
	var mat = sprite.get_material().duplicate()
	mat.set_shader_param("selected", flag)
	sprite.material = mat

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

func set_graphics(gid, gtype):
	#load graphics dor all states
	
	var sprite_sheet = $Sprite
	var shadow_sheet = $Shadow
	if gid in ResourceManager._object_sprite_meta:
		var atlas_coords = ResourceManager._object_sprite_meta[gid]
		sprite_sheet.region_rect.position = Vector2(atlas_coords[1]*32, atlas_coords[0]*64)
		sprite_sheet.region_rect.size = Vector2(32, 64)
		shadow_sheet.region_rect.position = Vector2(atlas_coords[1]*32, atlas_coords[0]*64)
		shadow_sheet.region_rect.size = Vector2(32, 64)
	
	#frames = load(ResourceManager.get_sprite_sheet(gid)).duplicate()
	
	pass
	
func update():
	var entity = EntityPool.get(entity_id)
	var gid = entity.components['graphics'].get_graphics_id()
	var gtype = entity.components['graphics'].get_gtype()
	set_graphics(gid, gtype)
	pass
