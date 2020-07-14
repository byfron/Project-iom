extends Node

#all signals that can be sent to the context
#TODO: if we end having lots of actions and systems and performance suffers, 
#we can use different signals for different actions, and have multiple queues
signal send_action(action)
signal pop_action(action)
signal interrupt_action(a1, a2)

signal toggle_debug_mode

# signals triggered when items in a dialog are selected
signal item_selected
signal update_inventory
signal item_button_pressed

signal select_entity
signal unselect_entity
signal highlight_entity
signal unhighlight_entity
signal highlight_tile
signal unhighlight_tile
signal highlight_action_button
signal unhighlight_all_buttons

signal show_inventory
signal hide_inventory

signal update_player_health

signal mouse_on_action
signal mouse_off_action

signal infopanel_show_item_info
signal inventory_show_item_info
signal stopped_hovering_item

signal player_chooses_dialog_option

signal mouse_out_of_gui

signal log_event


signal action_button_pressed
signal status_button_pressed
signal status_button_released


#signals related to verb panel
signal select_prev_verb
signal select_next_verb
signal activate_current_action
