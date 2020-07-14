extends PanelContainer
tool

onready var bar = $MarginContainer/Bar
onready var value_text = $HBoxContainer/Value
onready var title_text = $HBoxContainer/Title

export(String) var text setget set_text
export(Color) var color setget set_color
export(int) var max_value setget set_max_value
export(int) var value setget set_bar_value

var _percentage = 1.0
var _default_bar_size = 360
	
func set_max_value(max_v):
	max_value = max_v
	if Engine.editor_hint:
		var value_text = $HBoxContainer/Value
		value_text.text = str(value) + '/' + str(max_value)

func set_text(t):
	text = t
	if Engine.editor_hint:
		var title_text = $HBoxContainer/Title
		title_text.text = t

# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = 100
	#_default_bar_size = bar.rect_size.x
	
	#duplicate material to have unique sahders per instance
	#self.set_material(self.get_material().duplicate())
	set_color(color)
	refresh()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_color(c):
	color = c
	if Engine.editor_hint:
		var bar = $MarginContainer/Bar
		var style = StyleBoxFlat.new()
		style.set_bg_color(color)
		bar.set('custom_styles/panel', style)
	
		#bar.get_material().set_shader_param("color", color)
		#bar.get_stylebox().set_bg_color(color)

func increase_by(v):
	value += v
	refresh()
	
func decrease_by(v):
	value -= v
	refresh()

func refresh():
	title_text.text = text
	#bar.get_material().set_shader_param("color", color)
	#bar.get_material().set_shader_param("bar_percentage", value)
	_percentage = float(value)/max_value
	bar.rect_size.x = _default_bar_size * _percentage
	value_text.text = str(value) + '/' + str(max_value)
	
	var bar = $MarginContainer/Bar
	var style = StyleBoxFlat.new()
	style.set_bg_color(color)
	bar.set('custom_styles/panel', style)
		
func set_bar_value(v):
	value = v

	_percentage = float(value)/max_value
	if Engine.editor_hint:
		var bar = $MarginContainer/Bar
		#bar.get_material().set_shader_param("bar_percentage", value)	
		bar.rect_size.x = _default_bar_size * _percentage
		var value_text = $HBoxContainer/Value
		value_text.text = str(value) + '/' + str(max_value)
