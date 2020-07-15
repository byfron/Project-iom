extends Node
tool
var ActionFactory = load('res://game/core/ActionFactory.gd').new()

func process(context, delta):
	pass

func on_state_changed(action, context):
	pass
	
func execute_impl(action, context):
	pass

func start(action, context):
	#var node = context._entity2node[entity.id]
	#node.orientCharacterTowards(from_tile)
	
	#node.attacked(true)

#func execute_impl(action, context):
	var node = action.get_map_node(context)
	node.take_melee_damage(action.damage)
	
	var health_left = Utils.apply_damage(action.entity, action.damage)
	
	if health_left <= 0:
		var death_action = ActionFactory.create_death_action(action.entity)
		SignalManager.emit_signal('send_action', death_action)
		return
	
	if action.entity == context.get_player_entity():
		var health = action.entity.components['char_stats'].get_health()
		SignalManager.emit_signal("update_player_health", health)
		SignalManager.emit_signal("log_event", "Hit enemy!")
			
			
	#Add a knockdown if there's a critic
	#Compute discrete tile path for the trajectory
	var attacked_tile = Utils.get_entity_location(action.entity)
	
	var knockdown = false
	if knockdown:
	
		#knockdown X tiles in the direction of the attack
		var direction = (attacked_tile - action.from_tile).normalized()
		var dst_tile = attacked_tile + direction*3
		dst_tile.x = int(dst_tile.x)
		dst_tile.y = int(dst_tile.y)
		var tile_path = Utils.get_line_coords(attacked_tile, dst_tile)
	
		#Compute throw curve of the trajectory
		var throw_curve = Curve2D.new()
		var src_pos = Utils.getScreenCoordsTileCenter(tile_path[0])
		var dst_pos = Utils.getScreenCoordsTileCenter(tile_path[-1])
		throw_curve.add_point(src_pos)
		throw_curve.add_point(dst_pos)
	
		var knockdown_action = ActionFactory.create_knockdown_action(action.entity, tile_path, throw_curve)
		SignalManager.emit_signal('send_action', knockdown_action)
	
	pass
