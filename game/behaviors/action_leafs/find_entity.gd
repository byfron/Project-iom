extends "res://addons/godot-behavior-tree-plugin/action.gd"
var ActionFactory = load('res://game/core/ActionFactory.gd').new()
var Utils = load('res://game/utils/Utils.gd').new()

# Leaf Node
func tick(tick: Tick) -> int:

	var context = tick.blackboard.get('context')
	var actor = tick.actor
	var entity = EntityPool.get(actor.entity_id)
	var actor_tile = Utils.get_entity_location(entity)
	var player_tile = context.get_current_tile()
	var max_distance = 10
	
	print(EntityPool.get(actor.entity_id).name)
	
	#Remove surprised
	#TODO: kind of shameful that we do this here instead of from a aproper action
	actor.surprised(false)
	
	if context.player_is_dead:
		return FAILED
	
	#check if user is in the same level AND at a distance threshold
	if not (player_tile.z == actor_tile.z and (player_tile - actor_tile).length() < max_distance):
		return FAILED
		
	#Given actor orientation, draw a visibility cone
	var fov_cones = Utils.compute_fov_cones_from_orientation(actor.current_orientation)
	var position = Vector2(actor.coords.x, actor.coords.y)
	var entities = Utils.get_objects_in_fovcones(position, fov_cones, max_distance)
	
	if GameEngine.debug_mode:
		actor.show_fov_cone(position, fov_cones)
		
	#check if there's a line of sight to entity
	#var tiles = Utils.get_obstacles_in_fovline(context.world.fov_obstacles, actor_tile, player_tile)
	var values = Utils.get_values_in_fovline(context.world.fov_obstacles, actor_tile, player_tile)
	for v in values:
		#path is blocked by height 1, and player] is crouching
		if v == 1 and Utils.is_player_crouching():
			return FAILED
		if v > 1:
			return FAILED

	#TODO: at this point we should probably cache the tilepath, as it may be used in other
	#actions like jump attack (now we have duplicated code)
	
	#if the entity is crouching (or small) check if the tile right before is a volume,
	#or if it has height
	if Utils.is_player_crouching():
		var end_point = Utils.get_fovline_second_last(actor_tile, player_tile)
		var pvolumes = context.get_entities_in_2Dtile_plevel(end_point)
		if pvolumes:
			#We assume only one volume-entity per tile
			if 'volume' in pvolumes[0].components:
				return FAILED
	
	#If entity is not in the enemy list, get surprised, and add it
	var enemy_list = tick.blackboard.get('enemy_list')
	var el_idx = enemy_list.find(entity.id)
	if el_idx == -1:
		enemy_list.append(entity.id)
		var surprised_action = ActionFactory.create_surprised_action(entity, player_tile)
		SignalManager.emit_signal('send_action', surprised_action)
	
	
	#add 
	
	#If we found an entity, delete any possible path from memory
	actor.memory.remembered_path = null
	
	return OK
