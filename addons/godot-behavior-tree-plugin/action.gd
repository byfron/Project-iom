extends "res://addons/godot-behavior-tree-plugin/bt_base.gd"

# Leaf Node
func tick(tick: Tick) -> int:
	print('Running behavior!!')
	return OK
