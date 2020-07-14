extends HSplitContainer
tool

export var prop_name = '' setget set_prop_name
export(Texture) var prop_icon = null setget set_prop_icon 

func set_prop_name(n):
	prop_name = n
	if Engine.editor_hint:
		$Label.text = prop_name

func set_prop_icon(texture):
	prop_icon = texture
	if Engine.editor_hint:
		$MarginContainer/TextureRect.texture = prop_icon

func _ready():
	$Label.text = prop_name
	$MarginContainer/TextureRect.texture = prop_icon
