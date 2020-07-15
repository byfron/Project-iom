extends Node

var ECS = load('res://game/core/proto/ecs.gd')
var TILE_SIZE = 32

func load_from_json(file_name):
	var dict = {}
	var file = File.new()
	file.open(file_name, file.READ)
	var text = file.get_as_text()
	dict = parse_json(text)
	return dict
	
func inventory_to_container(inventory):
	var container = ECS.ContainerComponent.new()
	container._entities.value = inventory.get_stored_entities()
	return container
	
func remove_entity_from_ground(item_entity):
	var tile = Utils.get_entity_location(item_entity)
	GameEngine.context.remove_entity_from_tile(item_entity, tile)
	
	#delete item node from world
	GameEngine.context.delete_entity_node(item_entity)
	

func remove_entity_from_container(container_entity, entity):
	var container = container_entity.components['container']
	container._entities.value.erase(entity.id)
	
func change_behavior(context, entity, behavior):
	var comp = entity.components['behavior']
	comp.set_script(behavior)
	var btree_resource = 'res://game/behaviors/trees/' + comp.get_script() + '.tscn'
	var bree = load(btree_resource)	
	context.behavior_map[entity.id] = bree.instance()
	context.behavior_map[entity.id].init_behavior(context)
		
func invert_orientation_code(code):
	if code == 'N':
		return 'S'
	if code == 'NE':
		return 'SW'
	if code == 'E':
		return 'W'
	if code == 'SE':
		return 'NW'
	if code == 'S':
		return 'N'
	if code == 'SW':
		return 'NE'
	if code == 'W':
		return 'E'
	if code == 'NW':
		return 'SE'
		
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
func getScreenCoordsTileCenter(tile):
	return Vector2(tile.x * TILE_SIZE + 0.5*TILE_SIZE, tile.y * TILE_SIZE + 0.5*TILE_SIZE)

func getScreenCoords(tile):
	return Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
	
func screenToTile(xy):
	return Vector3(int(xy.x / TILE_SIZE), int(xy.y / TILE_SIZE), GameEngine.context.get_current_tile().z)
	
func get_line_coords(src, dst):
	
	assert(src.z == dst.z)
	var z = src.z
	
	var x0 = src.x
	var y0 = src.y
	var x1 = dst.x
	var y1 = dst.y
	var dx = abs(x1 - x0)
	var sx = -1
	if x0 < x1:
		sx = 1

	var dy = -abs(y1 - y0)
	var sy = -1
	if y0 < y1:
		sy = 1
			
	var err = dx + dy
	
	var points = []
	while(true):
		points.append(Vector3(x0, y0, z))
		if x0==x1 && y0==y1: break
		var e2 = 2*err
		if e2 >= dy:
			err += dy
			x0 += sx
			
		if e2 <= dx:
			err += dx
			y0 += sy

	return points
	
func set_entity_location(entity, tile):
	entity.components['location'].get_coord().set_x(tile.x)
	entity.components['location'].get_coord().set_y(tile.y)
	entity.components['location'].get_coord().set_z(tile.z)
	
func add_entity_location(entity, tile):
	var loc_comp = ECS.LocationComponent.new()
	loc_comp.new_coord()
	entity.components['location'] = loc_comp
	set_entity_location(entity, tile)
	
func get_entity_location(entity):
	var coord = entity.components['location'].get_coord()
	return Vector3(coord.get_x(), coord.get_y(), coord.get_z())

func is_player_crouching():
	var entity = GameEngine.context.get_player_entity()
	return entity.components['char_status'].get_crouching()

func get_fovline_second_last(start, stop):
	var num = (stop - start).length()+1
	var step = (stop - start) / (num - 1)
	var pos = start + step * (num-2)
	return Vector2(round(pos.x), round(pos.y))

func get_obstacles_in_fovline(map, start, stop):
	var num = (stop - start).length()+1
	var step = (stop - start) / (num - 1)
	var points = []
	var points_out = []
	for i in range(num):
		var pos = start + step * i
		pos = Vector2(round(pos.x), round(pos.y))
		if pos in map:
			points.append(pos)
		else:
			points_out.append(pos)
	return points

func get_values_in_fovline(map, start, stop):
	var num = (stop - start).length()+1
	var step = (stop - start) / (num - 1)
	var points = []
	for i in range(num):
		var pos = start + step * i
		pos = Vector2(round(pos.x), round(pos.y))
		if pos in map:
			points.append(map[pos])
		
	return points

func get_player_weapons():
	var player_entity = GameEngine.context.get_player_entity()
	var stored_entities = player_entity.components['inventory'].get_stored_entities()
	var weapons = []
	for ent_id in stored_entities:
		var ent = EntityPool.get(ent_id)
		if 'weapon' in ent.components:
			weapons.append(ent)
	return weapons

func get_component(entity, comp_name):
	if comp_name in entity.components:
		return entity.components[comp_name]
	
func weapon_equipped_is_ranged(entity):
	var inventory = entity.components['inventory']
	var equipped_entity = EntityPool.get(inventory.get_weilded_in_main_hand())
	var wcomponent = get_component(equipped_entity, 'weapon')
	if (wcomponent):
		var wrange = wcomponent.get_range()
		if wrange > 1:
			return true
	return false

func manhattan_dist(p1, p2):
	return max(abs(p1.x - p2.x), abs(p1.y - p2.y))

func distance_between_entities(e1, e2):
	var l1 = get_entity_location(e1)
	var l2 = get_entity_location(e2)
	return manhattan_dist(l1, l2)

func get_skill_of_weapon(wtype):
	if wtype == 0:
		return 'Brawler'
	elif wtype == 1:
		return 'Firearms'
		
	assert(false)

#TODO: maybe refactor in ECSUtils
func get_modified_skill(entity, skill_name):
	var skill_map = entity.components['skills'].get_skill_map()
	if skill_name in skill_map:
		return skill_map[skill_name]
	else:
		var msg = '%s was not found in skill_map' % skill_name
		Logger.warn(msg)
		assert(false)
		
func get_entity_weilded_weapon(entity):
	if entity.components.has('inventory'):
		var entity_weilded_id = entity.components['inventory'].get_weilded_in_main_hand()
		return EntityPool.get(entity_weilded_id)
	return null
	
static func apply_damage(entity, damage):
	
	#TODO: barrels take damage but have no char_stats
	if not 'char_stats' in entity.components:
		return 0
	
	var health = entity.components['char_stats'].get_health()
	var health_left = health - damage
	if health_left > 0:
		entity.components['char_stats'].set_health(health_left)
	else:
		entity.components['char_stats'].set_health(0)
		
	return health_left
		
