extends Node

onready var _current_scene = $Scene

#onready var _network_controller = $Controllers/NetworkController

#TOOD: REFACTOR
func protoTileToVec3(tile):
	return Vector3(tile.get_x(), tile.get_y(), tile.get_z())
	
func _ready():
	EntityPool.load_pool("res://maps/world.bin")
	var timer = $Timer
	start()

func start():
	var WorldScene = load("res://game/scenes/world/WorldScene.tscn")
	var world_scene = WorldScene.instance()
	
	#TODO: temporal. Sound per node seems to have issues when 
	#changing the scene	
	add_child(SoundManager)
	
	changeScene(world_scene)
	
func changeScene(scene_instance):
	_current_scene.remove_child(_current_scene.get_child(0))
	_current_scene.add_child(scene_instance)
