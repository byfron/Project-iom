extends Node2D
tool

#export(Node) var src_node = null
#export(Node) var dst_node = null
onready var chain = $Chain

var src_node = null
var dst_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#src_node = $Sprite
	#dst_node = $Sprite2
	
	if src_node and dst_node:
		chain.point_a = src_node.position
		chain.point_b = dst_node.position
		chain.recompute()
	
