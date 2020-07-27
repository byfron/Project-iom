extends Node2D

var anim_dictionary = {}
var _orient_code = 'N'
var current_animation = null
onready var anim_timer = $AnimTimer


func load_animations(gid, gtype):
	var metadata = ResourceManager.get_fx_anim_metadata(gtype)
	
	for anim_name in metadata:
		var sprite_anim = load('res://game/actors/SpriteAnimation.tscn').instance()
		
		#tmp: set just north direction for FX
		sprite_anim.directions = ['N']
		
		var texture = load(ResourceManager.get_fx_diffuse_sprite_sheet(anim_name, gid))
		sprite_anim.load_spritesheet(texture, null, metadata[anim_name])
		anim_dictionary[anim_name] = sprite_anim

func switch_anim(anim_name):
	if current_animation == anim_name:
		return
		
	current_animation = anim_name
	var old_children = $Animations.get_children()
	
	if anim_name in anim_dictionary:
		$Animations.add_child(anim_dictionary[anim_name])
		anim_dictionary[anim_name].update_orientation(_orient_code)
		
	for children in old_children:
		remove_child(children)
		
func start():
	anim_timer.start()
		
func set_frame(fidx):
	for current_sprite in $Animations.get_children():
		current_sprite.set_frame_index(fidx, _orient_code)
		
func frame_forward():
	for current_sprite in $Animations.get_children():
		current_sprite.frame_forward(_orient_code)
	
func orientCharacterTowards(code):
	return
	#_orient_code = code
	for current_sprite in $Animations.get_children():
		current_sprite.update_orientation(_orient_code)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var fidx = 0
	
func _on_Timer_timeout():
	frame_forward()
	pass # Replace with function body.
