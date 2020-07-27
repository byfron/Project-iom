extends Node

var current_frame_dict = {}
var _orient_code = 'N'
var anim_dictionary = {}
var anim_weapon_dictionary = {}
var current_animation = null

func load_animations(gid, gtype):
	var metadata = ResourceManager.get_char_anim_metadata(gtype)
	
	for anim_name in metadata:
		var sprite_anim = load('res://game/actors/SpriteAnimation.tscn').instance()
		var texture = load(ResourceManager.get_char_diffuse_sprite_sheet(anim_name, gid))
		var normal_map  = load(ResourceManager.get_char_normal_sprite_sheet(anim_name, gid))
		sprite_anim.load_spritesheet(texture, normal_map, metadata[anim_name])
		anim_dictionary[anim_name] = sprite_anim
		
func load_weapon_animations(gid, gtype):
	var metadata = ResourceManager.get_char_object_anim_metadata(gtype)
	
	for anim_name in metadata:
		var sprite_anim = load('res://game/actors/SpriteAnimation.tscn').instance()
		var texture = load(ResourceManager.get_char_object_diffuse_sprite_sheet(anim_name, gid))
		#var normal_map  = load(ResourceManager.get_char_object_normal_sprite_sheet(anim_name, gid))
		sprite_anim.load_spritesheet(texture, null, metadata[anim_name])
		anim_weapon_dictionary[anim_name] = sprite_anim


func invert_direction(code):
	pass
	
func switch_anim(anim_name):
	if current_animation == anim_name:
		return
		
	current_animation = anim_name
		
	var old_children = get_children()
	
	if anim_name in anim_dictionary:
		add_child(anim_dictionary[anim_name])
		anim_dictionary[anim_name].update_orientation(_orient_code)
		
	if anim_name in anim_weapon_dictionary:
		add_child(anim_weapon_dictionary[anim_name])
		anim_weapon_dictionary[anim_name].update_orientation(_orient_code)
		
#	if anim_name in anim_fx_dictionary:
#		add_child(anim_fx_dictionary[anim_name])
#		anim_fx_dictionary[anim_name].update_orientation(_orient_code)
	
	#Free old children
	for children in old_children:
		remove_child(children)
		
#	for current_sprite in get_children():
#		remove_child(current_sprite)
#		add_child(anim_dictionary[anim_name])
#		anim_dictionary[anim_name].update_orientation(_orient_code)
		
func set_frame(fidx):
#	assert(fidx < num_frames_per_orient)
	for current_sprite in get_children():
		current_sprite.set_frame_index(fidx, _orient_code)
	
func set_selected(flag):
	for anim_name in anim_dictionary:
		var current_sprite = anim_dictionary[anim_name]
		var mat = current_sprite.get_material().duplicate()
		mat.set_shader_param("selected", flag)
		current_sprite.material = mat

func set_magic(flag):
	for anim_name in anim_dictionary:
		var current_sprite = anim_dictionary[anim_name]
		var mat = current_sprite.get_material().duplicate()
		mat.set_shader_param("magic", flag)
		current_sprite.material = mat
	
func set_frozen(flag):
	for anim_name in anim_dictionary:
		var current_sprite = anim_dictionary[anim_name]
		var mat = current_sprite.get_material().duplicate()
		mat.set_shader_param("frozen", flag)
		current_sprite.material = mat
	
func set_attacked(flag):
	for anim_name in anim_dictionary:
		var anim = anim_dictionary[anim_name]
		var mat = anim.get_material().duplicate()
		mat.set_shader_param("attacked", flag)
		anim.material = mat
		
func frame_forward():
	for current_sprite in get_children():
		current_sprite.frame_forward(_orient_code)
	
func get_current_frame():
	return $SpriteAnimation
	
func get_current_frame_rect():
	var anim = anim_dictionary[current_animation]
	var current_sprite = get_children()[0]
	var frame_idx = current_sprite.frame_idx
	var sprect = current_sprite.get_rect()
	var size_w = sprect.size[0]
	var size_h = sprect.size[1]
	var row = int(frame_idx/anim.num_frames_per_orient)
	var col = frame_idx%anim.num_frames_per_orient
	return Rect2(row*size_h, col*size_w, size_h, size_w)
	
func orientCharacterTowards(code):	
	_orient_code = code
	for current_sprite in get_children():
		current_sprite.update_orientation(_orient_code)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var fidx = 0
