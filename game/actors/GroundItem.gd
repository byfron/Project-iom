extends Node2D

onready var alpha_tween = $AlphaTween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func select(flag):
	pass
	
func add_item_entity(item_entity):
	var item_button = load('res://game/ui/actions/ItemButton.tscn').instance()
	
	#compute location of the item
	var num_entities = $UINode/Buttons.get_child_count()
	item_button.item_entity = item_entity
	item_button.rect_position.x = -27
	item_button.rect_position.y = -(50 + 15)*(num_entities) - 15
	var itype = item_entity.components['item'].get_itype()
	item_button.image = load(ResourceManager.get_item_icon_sprite(itype)).duplicate()
	
	$UINode/Buttons.add_child(item_button)

func show_buttons():
	alpha_tween.interpolate_property($UINode, "modulate", Color(1,1,1,0), Color(1,1,1,1), .8, Tween.TRANS_SINE, Tween.EASE_OUT)
	alpha_tween.start()
	
func hide_buttons():
	alpha_tween.interpolate_property($UINode, "modulate", Color(1,1,1,1), Color(1,1,1,0), .8, Tween.TRANS_SINE, Tween.EASE_OUT)
	alpha_tween.start()
