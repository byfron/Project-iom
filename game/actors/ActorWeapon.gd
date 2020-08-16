extends Node2D
tool

#TODO make this a global constant
var directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']
var direction_vectors = {
	'N': Vector2(0, -1), 
	'NE':Vector2(1, -1),
	'E': Vector2(1,  0),
	'SE':Vector2(1,  1),
	'S': Vector2(0,  1),
	'SW':Vector2(-1, 1),
	'W': Vector2(-1, 0),
	'NW':Vector2(-1,-1)
}
	
#GUN
var values = [Vector2(2.0, -28.2), Vector2(16.81, -21.99), Vector2(26, -14), Vector2(14.1,0.366), Vector2(-2.32, 4.73), Vector2(-17.36, -0.33), Vector2(-26.0, -14.0), Vector2(-14.74, -24.28)]

#SHOTGUN
#var values = [Vector2(2.13, -23.05), Vector2(18.20, -13.94), Vector2(24.02, -2.71), Vector2(13.56, 7.55), Vector2(-1.55, 16.65), Vector2(-16.65, 3.87), Vector2(-23.24, -7.55), Vector2(-12.78, -17.24)]

export(Dictionary) var weapon_keypoints = {}

func _ready():
	
	var idx = 0
	for dir in directions:
		weapon_keypoints[dir] = values[idx]
		idx += 1

func get_weapon_endpoint(direction):
	
	#TODO: we may have more types of keypoints
	return weapon_keypoints[direction] 

func shoot_shotgun(direction, node):
	var particles = $ShotgunParticles
	
	var end_point = get_weapon_endpoint(direction)
	
	var dir_vec = node.global_position - self.global_position
	
	#var dir_vec = direction_vectors[direction]
	particles.process_material.direction.x = dir_vec.x
	particles.process_material.direction.y = dir_vec.y
	particles.show()
	particles.position = end_point
	particles.emitting = true
