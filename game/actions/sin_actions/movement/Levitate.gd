extends "res://game/actions/user_actions/UserAction.gd"
var path = []
	
func start_impl(context):
	
	var node = context.get_entity_node(entity)
	node.enable_glow_color(Color(30.0, 1.0, 1.0))
	

func on_finish(context):
	pass
	#Put back idle animation on exit
	#var node = context.get_entity_node(entity)
	#node.set_animation("Idle")
	#node.set_frame(0)
		
	#node.stop_ghosting()

func on_state_changed(action, context):
	var tile = path.pop_front()
	if not tile:
		finish_action()
		return
	
	#If our tile is under attack, moving is dodging roll!
	var node = context.get_entity_node(entity)
	tile = Vector3(tile.x, tile.y, node.coords.z)
	node.orientCharacterTowards(tile)

	if tile and context.is_walkable(tile):
		context.move_entity_to_tile(entity, tile, true)
		entity.components['location'].get_coord().set_x(tile.x)
		entity.components['location'].get_coord().set_y(tile.y)


	#create lighting jolt
	#var jolt = load("res://game/fx/LightningJolt.tscn").instance()
	#node.add_child(jolt)
	#jolt.create(Vector2(0,0), context.get_player_node().position - node.position)
	
