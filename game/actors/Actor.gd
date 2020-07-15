extends Node2D
tool

#TODO: clean up plenty tweens

var entity_name = null;
var entity_id = null;
var actions = []
var coords = null
var current_orientation = 'E'
var move_tween = Tween.new()
var attack_tween = Tween.new()
var moveback_tween = Tween.new()
var life_tween = Tween.new()
var miss_tween = Tween.new()
var under_attack = false
var lifelabel_starting_pos = null
var lifelabel_starting_color = null
var misslabel_starting_pos = null
var misslabel_starting_color = null
var _flipped = false
var _state_offset = Vector2(0,0)
#var airborn = false

onready var occluder_mask = $LightMask
onready var loot_effect = $LootInContainer

export(Texture) var image setget set_image
export(Color) var color setget set_color

var non_tweened_position = null

var orientation_angle = {
	'N': -180,
	'NE': -135,
	'E': -90,
	'SE': -45,
	'S': 0,
	'SW': 45,
	'W': 90,
	'NW': 135
}

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

func load_animation(gid, gtype):
	var actor_sprite = $ActorSprite
	actor_sprite.load_animations(gid, gtype)
	
func _ready():
	self.add_child(move_tween)
	self.add_child(attack_tween)
	self.add_child(moveback_tween)
	self.add_child(life_tween)
	self.add_child(miss_tween)
	life_tween.connect("tween_completed", self, "finished_damage_tween")
	miss_tween.connect("tween_completed", self, "finished_miss_tween")
	$AttackedTimer.connect("timeout", self, "attacked_timer_ended")
	$AttackedTimer.wait_time = GameEngine.MAX_TURN_TIME
	$IdleTimer.connect("timeout", self, "back_to_idle")
	
	var actor_sprite = $ActorSprite
	actor_sprite.switch_anim("Running")
	actor_sprite.orientCharacterTowards(current_orientation)
	
	non_tweened_position = position
		
func refresh_position():
	#Computes pos of actor from current coords
	position = Utils.getScreenCoordsTileCenter(coords)

func init():
	pass
	
#TODO: use key-strokes from settings
func orientCharacterTowards(tile, invert_flag = false):
	var offset = (Vector2(coords.x, coords.y) - Vector2(tile.x, tile.y))
	var angle = offset.angle_to(Vector2(0, -1))
	
	var orient_arc = 2*PI/8
	
	var orient_code = ''
	
	if offset.x == 0 and offset.y == 1:
		orient_code = 'N'
	elif offset.x == 0 and offset.y == -1:
		orient_code = 'S'
	elif (angle >= (7.0/2)*orient_arc and angle <= PI) or (angle >= -PI and angle <= -(7.0/2)*orient_arc):
		orient_code = 'N'
	elif (angle >= 0 and angle <= orient_arc/2) or (angle <= 0 and angle >= -orient_arc/2):
		orient_code = 'S'
	else:
		if angle >= 0:
			if angle >= (5.0/2)*orient_arc and angle <= (7.0/2)*orient_arc:
				orient_code = 'NE'
			elif angle >= (3.0/2)*orient_arc and angle <= (5.0/2)*orient_arc:
				orient_code = 'E'
			elif angle >= orient_arc/2 and angle <= (3.0/2)*orient_arc:
				orient_code = 'SE'
		else:
			angle = -angle
			if angle >= (5.0/2)*orient_arc and angle <= (7.0/2)*orient_arc:
				orient_code = 'NW'
			elif angle >= (3.0/2)*orient_arc and angle <= (5.0/2)*orient_arc:
				orient_code = 'W'
			elif angle >= orient_arc/2 and angle <= (3.0/2)*orient_arc:
				orient_code = 'SW'
				
	if not orient_code:
		print('Error: couldnt compute orientation!')
		orient_code = 'S'

	if invert_flag:
		orient_code = Utils.invert_orientation_code(orient_code)
	
	current_orientation = orient_code
	$ActorSprite.orientCharacterTowards(orient_code)
			
func select(flag):
	$ActorSprite.set_selected(flag)

func attacked(flag):
	#set up a timer to bring this back to normal
	$ActorSprite.set_attacked(flag)
	$AttackedTimer.start()
	
func attacked_timer_ended():
	$ActorSprite.set_attacked(false)
	
func set_debug_label(text):
	$DebugLabel.text = text
	
func switch_anim(anim):
	$ActorSprite.switch_anim(anim)
			
func create_ghost_trail():
	pass
	
func moveTo(tile, pos, use_tween=true):
	coords = tile
	pos += _state_offset
		
	if use_tween:
		non_tweened_position = pos
		move_tween.interpolate_property(self, "position",
		get_position(), pos, 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
		move_tween.start()
	else:
		self.position = pos
	
func set_frame(frame_idx):
	$ActorSprite.set_frame(frame_idx)
	
func fire_weapon():
	var angle = orientation_angle[current_orientation]
	var wlight = $WeaponFireNode/WeaponFire/WeaponLight
	wlight.energy = 5.0
	
	$WeaponFireNode.modulate = Color(1,1,1,1)
	$WeaponFireNode.position = $ActorSprite.position + $ActorWeapon.get_weapon_endpoint(current_orientation)
	$WeaponFireNode/WeaponFire.rotation_degrees = angle
	$WeaponFireNode.show()
	var tween = $WeaponFireNode/Tween
	tween.interpolate_property($WeaponFireNode, "modulate", Color(1,1,1,1), Color(1,1,1,0), .2, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(wlight, "energy", 5.0, 0.0, .2, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	
	
func surprised(flag):
	if flag:
		$SurprisedSprite.show()
	else:
		$SurprisedSprite.hide()
		
func back_to_idle():
	if $ActorSprite.current_animation == 'Running':
		set_animation('Idle')
	
func set_animation(animation):
	$ActorSprite.switch_anim(animation)
	
func anim_frame_forward():
	$ActorSprite.frame_forward()
	
func get_weapon_endpoint():
	return global_position + $ActorSprite.position + $ActorWeapon.get_weapon_endpoint(current_orientation)
	
func set_burning_state(flag):
	$FX/FEMALE_PAIN_01.play()
	
func set_floating_state(flag):
	if flag:
		_state_offset.y = +32
		$SplashParticles.emitting = true
		$shadow.hide()
		$FX/WATER_SPLASH_01.play()
	else:
		_state_offset.y = 0
		$shadow.show()
		
	$ActorAnimation.set_sinking(flag)
	
func shoved(new_coord):
	pass
	
func on_action(action):
	pass
	
func move_back():
	moveback_tween.start()
	
func melee_attack(node):
	position = non_tweened_position
	reset_attack_tweens()
	var global_pos = get_global_position()
	var dir = node.get_global_position() - global_pos
	var curr_pos = get_position()
	
func miss_attack():
	reset_miss_tweens()
	
	var curr_pos = misslabel_starting_pos
	var color = misslabel_starting_color
	var miss_label = $MissLabel
	miss_tween.interpolate_property(miss_label, "rect_position", curr_pos, 
									curr_pos - Vector2(0,20), 1, 
									Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	miss_tween.interpolate_property(miss_label, "modulate", color, 
									Color(color.r, color.g, color.b, 0.0), 1, 
									Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	miss_label.text = str("Miss")
	miss_label.show()
	miss_tween.start()
	
func take_damage(damage):
	$LifeAfterHit.start(damage)
	return
	
	reset_life_tweens()
	var curr_pos = lifelabel_starting_pos
	var color = lifelabel_starting_color
	
	#TODO: create new instance and destroy at the end of tween
	var life_label = $LifeLabel
	life_tween.interpolate_property(life_label, "rect_position", curr_pos, 
									curr_pos - Vector2(0,40), 1, 
									Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	life_tween.interpolate_property(life_label, "modulate", color, 
									Color(color.r, color.g, color.b, 0.0), 1, 
									Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	life_label.text = '-' + str(damage)
	life_label.show()
	life_tween.start()
	
func take_melee_damage(damage):
	take_damage(damage)
	
func finished_damage_tween(obj, key):
	var life_label = $LifeLabel
	life_label.hide()
	life_label.modulate = lifelabel_starting_color
	life_label.rect_position = lifelabel_starting_pos
	
func finished_miss_tween(obj, key):
	var miss_label = $MissLabel
	miss_label.hide()
	miss_label.modulate = misslabel_starting_color
	miss_label.rect_position = misslabel_starting_pos
	
func reset_attack_tweens():
	attack_tween.stop_all()
	
func reset_miss_tweens():
	miss_tween.stop_all()
	var miss_label = $MissLabel
	miss_label.hide()
	miss_label.modulate = misslabel_starting_color
	miss_label.rect_position = misslabel_starting_pos
	
func reset_life_tweens():
	life_tween.stop_all()
	var life_label = $LifeLabel
	life_label.hide()
	life_label.modulate = lifelabel_starting_color
	life_label.rect_position = lifelabel_starting_pos

func enable_light():
	$Light2D.enabled = true
	
func show_meta_tele_attack():
	$MetaIcon.show()
	
func hide_meta():
	$MetaIcon.hide()
	
func start_ghosting():
	$GhostTimer.start()

func stop_ghosting():
	$GhostTimer.stop()
		
func _on_GhostTimer_timeout():
	var ghost = preload("res://game/actors/GhostEffect.tscn").instance()
	get_parent().add_child(ghost)
	ghost.position = position + $ActorSprite.position
	ghost.texture = $ActorSprite.get_current_frame().texture
	ghost.normal_map = $ActorSprite.get_current_frame().normal_map
	ghost.vframes = $ActorSprite.get_current_frame().vframes
	ghost.hframes = $ActorSprite.get_current_frame().hframes
	ghost.frame = $ActorSprite.get_current_frame().frame
	
