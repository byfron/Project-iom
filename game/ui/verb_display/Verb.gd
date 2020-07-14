tool
extends CenterContainer


export var selected = true setget set_selected
export var verb_name = "" setget set_verb_name
var color = Color(0.098039, 0.403922, 0.086275, 0)

func set_verb_name(text):
	verb_name = text
	if Engine.editor_hint:
		$TopMargin/VerbMargin/VerbName.text = text


func set_selected(flag):
	selected = flag
	if flag:
		color.a = 0.86275
	else:
		color.a = 0.0
		
	var new_style = $TopMargin/Background.get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	$TopMargin/Background.set("custom_styles/panel", new_style)
	
func _ready():
	set_selected(selected)
	set_verb_name(verb_name)
	var new_style = $TopMargin/Background.get_stylebox("panel").duplicate()
	new_style.set_bg_color(color)
	$TopMargin/Background.set("custom_styles/panel", new_style)
	$TopMargin/VerbMargin/VerbName.text = verb_name
