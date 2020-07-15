extends "UserAction.gd"
var attacked_tiles = null
var old_tile = null
var screen_old_tile = null
var screen_attacked_tile = null
var entity_hit_map = {}

func start_impl(context):
	screen_old_tile = Utils.getScreenCoordsTileCenter(old_tile)
	screen_attacked_tile = Utils.getScreenCoordsTileCenter(attacked_tiles[-1])
	
	#
	#TODO: if there's an item in the current tile apply damage

			#
func compute_damage():
	return 10
	pass
	
func process_impl(context, turn_time):
	
	if current_state == 1:
		var pos = screen_old_tile.linear_interpolate(screen_attacked_tile, turn_time/(GameEngine.MAX_TURN_TIME))
		var node = get_map_node(context)
		node.position = pos
		
		#if in entity in map, send action and pop entity from list
		var tile = Utils.screenToTile(pos)
		if tile in entity_hit_map:
			var action = ActionFactory.create_takehit_action(entity_hit_map[tile], screen_old_tile, 10)
			SignalManager.emit_signal('send_action', action)
			entity_hit_map.erase(tile)
		
		#Change frame to stump before hitting the floor
		if turn_time >= GameEngine.MAX_TURN_TIME * (3.0/4):
			node.anim_frame_forward()
		#	change_state(context)
		#	pass
	
func on_state_changed(action, context):
	#screen_old_tile = Utils.getScreenCoordsTileCenter(old_tile)
	
	#freeze the player while we jump... this sucks
	#maybe send a high priority action that blocks the player?
	
	#if current_state == 2:
	#	GameEngine.cinematic_state = false
		
	#if current_state == 2:
	#	GameEngine.player_is_frozen = false
	
	if current_state == 0:
		for t in attacked_tiles:
			#TODO: Get hittable entities (we assume only one)
			var entities = context.get_entities_in_tile(t)
			if entities:
				#make sure we are not hitting ourselves (lol)
				if entities[0].id != action.entity.id:
					entity_hit_map[t] = entities[0]
		
		var node = get_map_node(context)
		node.start_ghosting()
		
	if current_state == 0:
		GameEngine.cinematic_state = true
	if current_state == 2:
		GameEngine.cinematic_state = false
		var node = get_map_node(context)
		node.stop_ghosting()

func on_finish(context):
	GameEngine.cinematic_state = false
	pass


func execute_impl(action, context):
	context.move_entity_to_tile(action.entity, attacked_tiles[-1])
	
