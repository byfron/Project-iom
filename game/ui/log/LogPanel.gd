extends Node2D

var LogEntry = load('res://game/ui/log/LogEntry.tscn')
onready var log_container = $MarginContainer/VBoxContainer
var max_log_entries = 10

func _ready():
	SignalManager.connect("log_event", self, "add_log_entry")
	
	pass

func add_log_entry(text):
	var entry = LogEntry.instance()
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.log_text = text
	log_container.add_child(entry)
	
	#re-assign transparency
	var all_entries = log_container.get_children()
	all_entries.invert()
	var idx = 0
	for entry in all_entries:
		if idx >= 10:
			log_container.remove_child(entry)
		else:
			entry.modulate.a = 1 - float(idx)/max_log_entries
		idx += 1
