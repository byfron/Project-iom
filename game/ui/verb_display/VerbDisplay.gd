tool
extends Node2D

var verb_scenes = []
var action_list = []
var selected_verb = 0
onready var motion_tween = $MotionTween

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("select_prev_verb", self, "select_prev_verb")
	SignalManager.connect("select_next_verb", self, "select_next_verb")
	SignalManager.connect("activate_current_action", self, "activate") 
	
func select_verb(idx):
	verb_scenes[idx].set_selected(true)
	var current_verb = verb_scenes[idx]
	var offset = $PanelContainer.rect_size.y/2.0 - current_verb.rect_size.y/2.0
	var future_pos = $PanelContainer/ControlNode.get_position()
	future_pos.y = -idx * current_verb.rect_size.y + offset
	motion_tween.interpolate_property($PanelContainer/ControlNode, "position",
		$PanelContainer/ControlNode.get_position(), future_pos, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	motion_tween.start()
	
func display_entity_actions(entity):
	clear_verbs()
	for action_type in ActionManager.action_map:
		for action in ActionManager.action_map[action_type]:
			action_list.append(action)
			add_verb(action.action_name)
	
func select_prev_verb():
	if selected_verb < len(verb_scenes)-1:
		verb_scenes[selected_verb].set_selected(false)
		selected_verb +=1
		select_verb(selected_verb)

func clear_verbs():
	verb_scenes = []
	action_list = []
	Utils.delete_children($PanelContainer/ControlNode/MarginContainer/VerbContainer)
	
func select_next_verb():
	if selected_verb > 0:
		verb_scenes[selected_verb].set_selected(false)
		selected_verb -=1
		select_verb(selected_verb)

func activate():
	var action = action_list[selected_verb]
	pass

func add_verb(verb_name):
	var verb_scene = load("res://game/ui/verb_display/Verb.tscn").instance()
	verb_scene.set_verb_name(verb_name)
	verb_scene.set_selected(false)
	$PanelContainer/ControlNode/MarginContainer/VerbContainer.add_child(verb_scene)
	verb_scenes.append(verb_scene)

func _on_PanelContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_DOWN:
				SignalManager.emit_signal("select_prev_verb")
				
			if event.button_index == BUTTON_WHEEL_UP:
				SignalManager.emit_signal("select_next_verb")
