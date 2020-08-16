extends "UserAction.gd"

var attacked_tile = null
var weapon_entity = null

var bolt_node = null
var src_position = null
var dst_position = null
var t = 0

func start_impl(context):
	pass
	#$AttackSubAction.attacked_entity = attacked_entity
	#$AttackSubAction.weapon_entity = null

func execute_impl(action, context):
	pass
	
func on_state_changed(action, context):
	
	if current_state == 1:
		var node = get_map_node(context)
			
		
		node.get_node("FX").get_node('SPELL').play()
				
		#Throw frost fire or whatever magic we have selected.
		#Animation should start on execution and last two turns. 
		#Execution and recovery.
		bolt_node = load('res://game/actors/FX/MagicBolt.tscn').instance()
		
		#set absolute poisition
		bolt_node.total_time = GameEngine.MAX_TURN_TIME * 2
		bolt_node.position = node.position
		src_position = node.position
		dst_position = Utils.getScreenCoordsTileCenter(attacked_tile)
		
		#Attach bolt to actor_layer
		var actor_layer = context.world.world_map.actor_layer
		actor_layer.add_actor_child(bolt_node)
	
func on_finish(context):
	bolt_node.explode()
	var node = get_map_node(context)
	node.get_node("FX").get_node('FREEZE').play()
	pass

func process_impl(context, turn_time):
	
	if current_state < 1:
		return
		
	var current_time = (current_state - 1)*GameEngine.MAX_TURN_TIME + turn_time
	print('state', current_state)
	print('turn_time', turn_time)
	
	if src_position:
		var normalized_action_time = current_time / (2*GameEngine.MAX_TURN_TIME)
		print('time',normalized_action_time)
		bolt_node.position = src_position.linear_interpolate(dst_position, normalized_action_time)
		
		bolt_node.set_animation(normalized_action_time)
	
