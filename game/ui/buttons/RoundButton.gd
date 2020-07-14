extends MarginContainer
tool

export(Texture) var image setget assign_image
export(Color) var color setget set_color

func set_color(col):
	color = col
	if Engine.editor_hint:
		var new_style = $Panel.get_stylebox("panel").duplicate()
		new_style.set_bg_color(color)
		$Panel.set("custom_styles/panel", new_style)

func assign_image(im):
	image = im
	if Engine.editor_hint:
		$MarginContainer/Icon.texture = im

func _ready():
	$MarginContainer/Icon.texture = image
	var new_style = $Panel.get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	$Panel.set("custom_styles/panel", new_style)
