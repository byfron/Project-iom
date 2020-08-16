extends CanvasLayer

func toggle_visibility():
	$Panel.visible = not $Panel.visible 

# Debug overlay by Gonkee - full tutorial https://youtu.be/8Us2cteHbbo

var stats = []
var map_entries = {}

func show():
	$Panel.show()
	
func hide():
	$Panel.hide()

func add_stat(stat_name, object, stat_ref, is_method):
	stats.append([stat_name, object, stat_ref, is_method])

func add_map_entry(entry_name, entry_value):
	map_entries[entry_name] = entry_value
	pass

func _process(delta):
	var label_text = ""
	
	var fps = Engine.get_frames_per_second()
	label_text += str("FPS: ", fps)
	label_text += "\n"
	
	var mem = OS.get_static_memory_usage()
	label_text += str("Static Memory: ", String.humanize_size(mem))
	label_text += "\n"
	
	var tile = GameEngine.context.get_current_tile()
	label_text += str("Selected tile: ", str(tile))
	label_text += "\n"
	
	for s in stats:
		var value = null
		
		if s[1] and weakref(s[1]).get_ref():
			if s[3]:
				value = s[1].call(s[2])
			else:
				value = s[1].get(s[2])
		label_text += str(s[0], ": ", value)
		label_text += "\n"
		
	#for e in map_entries:
	#	label_text += str(e, ": ", map_entries[e])
	#	label_text += "\n"
	
	$Panel/Label.text = label_text
