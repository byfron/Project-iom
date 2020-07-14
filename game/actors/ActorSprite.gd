extends Node

var current_frame_dict = {}
var _orient_code = 'N'
var _metadata = null
var anim_dictionary = {}
var current_animation = null

func load_animations(gid, gtype):
	_metadata = ResourceManager.get_char_anim_metadata(gtype)
	
	for anim_name in _metadata:
		var sprite_anim = load('res://game/actors/SpriteAnimation.tscn').instance()
		sprite_anim.load_spritesheet(anim_name, _metadata[anim_name], gid)
		anim_dictionary[anim_name] = sprite_anim

func invert_direction(code):
	pass
	
func switch_anim(anim_name):
	current_animation = anim_name
	if not anim_name in anim_dictionary:
		assert(false)
		return 
		
	var current_sprite = get_child(0)
	remove_child(current_sprite)
	add_child(anim_dictionary[anim_name])
	anim_dictionary[anim_name].update_orientation(_orient_code)
	
	#current_frame_dict = frame_dictionary[anim_name]
	#var anim_meta = _metadata[anim_name]
	#animation = anim_name
	#num_frames_per_orient = int(anim_meta['frames'])
#	var frame_tex = frames.get_frame(anim_name, 0)
	
#	if anim_meta['auto']:
#		#Launch tween that plays all animation
#		var tween = $AutoAnimTween
#		tween.interpolate_property(
#			self, "frame", 0, 3, 0.5,
#			Tween.TRANS_LINEAR, Tween.EASE_IN)
#		tween.start()
		
func set_frame(fidx):
#	assert(fidx < num_frames_per_orient)
	var current_sprite = get_child(0)
	current_sprite.set_frame_index(fidx, _orient_code)
	
func set_selected(flag):
	for anim_name in anim_dictionary:
		var anim = anim_dictionary[anim_name]
		var mat = anim.get_material().duplicate()
		mat.set_shader_param("selected", flag)
		anim.material = mat
	
func set_attacked(flag):
	for anim_name in anim_dictionary:
		var anim = anim_dictionary[anim_name]
		var mat = anim.get_material().duplicate()
		mat.set_shader_param("attacked", flag)
		anim.material = mat
		
func frame_forward():
	var current_sprite = get_child(0)
	current_sprite.frame_forward(_orient_code)
	
func get_current_frame():
	return $SpriteAnimation
	
func orientCharacterTowards(code):
	_orient_code = code
	var current_sprite = get_child(0)
	current_sprite.update_orientation(_orient_code)
	
	#self.frame = current_frame_dict[_orient_code] + frame_idx
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var fidx = 0
