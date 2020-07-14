extends Node

var obstacle_map = null
var pathfind = preload("res://game/utils/AStar/pathfind.gd").new()

func _ready():
	pass # Replace with function body.

func set_obstacles(obstacles):
	obstacle_map = obstacles
	
func compute_path(start_tile, end_tile):
	
	if end_tile in obstacle_map:
		return []
		
	var path = pathfind.astar(obstacle_map, start_tile, end_tile)
	return path
