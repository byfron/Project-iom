extends "UserAction.gd"

#TODO: make it static?
var ActionFactory = load('res://game/core/ActionFactory.gd').new()
var thrown_entity = null

func _init():
	signal_on_touch = "overlay_aim_mode"

func start_impl(context):
	var node = context.get_entity_node(entity)
	node.orientCharacterTowards(Utils.get_entity_location(GameEngine.context._selected_entity))

func execute_impl(action, context):
	
	var coord = Utils.get_entity_location(entity)
	context.create_item(thrown_entity, coord)
	
	#rotate the graphics and move it up
	var node = context.get_entity_node(thrown_entity)
	node.enable_fake_shadowing()
	
	#Add bottle to active entities in context
	context.native_entities.append(thrown_entity)
	
	#compute throw curve and pass it to the fly action
	#compute linear trajecory of tiles
	var throw_to_tile = Utils.get_entity_location(GameEngine.context._selected_entity)
	
	#Compute discrete tile path for the trajectory
	var tile_path = Utils.get_line_coords(coord, throw_to_tile)
	
	#Compute throw curve of the trajectory
	var throw_curve = Curve2D.new()
	var src_pos = Utils.getScreenCoords(coord)
	var dst_pos = Utils.getScreenCoords(throw_to_tile)
	throw_curve.add_point(src_pos, Vector2(0,0), Vector2(0, -32))
	throw_curve.add_point(dst_pos + Vector2(16, -16))#, Vector2(dst_pos.x, dst_pos.y - 16), dst_pos)
	
	
	#var direction = (throw_to_entity - coord).normalized()
	#var strength = 1
			
	#emit an action of fly
	var fly_action = ActionFactory.create_fly_action(thrown_entity, throw_curve, tile_path)
	SignalManager.emit_signal('send_action', fly_action)
	
	
	pass
