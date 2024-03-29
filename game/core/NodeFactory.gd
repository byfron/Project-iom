extends Node
var Utils = load('res://game/utils/Utils.gd').new()
var ECS = load('res://game/core/proto/ecs.gd')

func createCampFireNode(context, entity):
	var camp_fire_node = load('res://game/actors/lights/camp_fire.tscn').instance()
	var coord = entity.components['location'].get_coord()
	var tile_location = Vector2(coord.get_x(), coord.get_y())
	var tile_offset = Utils.getScreenCoords(tile_location)
	camp_fire_node.position = Vector2(tile_offset.x + 32, tile_offset.y + 32)
	return camp_fire_node

func createTorchNode(context, entity):
	var torch_node = load('res://game/actors/lights/torch.tscn').instance()
	var coord = entity.components['location'].get_coord()
	var tile_location = Vector2(coord.get_x(), coord.get_y())
	var tile_offset = Utils.getScreenCoords(tile_location)
	torch_node.position = Vector2(tile_offset.x + 32, tile_offset.y)
	return torch_node

func createFXNode(context, pos):
	var fxnode = load('res://game/actors/decorations/Decoration.tscn').instance()
	fxnode.position = pos
	return fxnode

#ALL NODES BRING JUST THE AUDIO-VISUAL INFO
func createLightNode(context, entity):
	var light_node = load('res://game/actors/lights/spot_light.tscn').instance()
	var coord = entity.components['location'].get_coord()
	var tile_location = Vector2(coord.get_x(), coord.get_y())
	var tile_offset = Utils.getScreenCoords(tile_location)
	light_node.position = Vector2(tile_offset.x + 32, tile_offset.y)
	return light_node

#TODO: maybe doors should have a node?
func createSoundNode(context, entity):
	var node = load("res://game/actors/SoundNode.tscn").instance()
	var sound_map = entity.components['sound'].get_sound_map()
	node.load_sounds(sound_map)
	return node

func createPlayerActorNode(entity):
	var node = load("res://game/actors/PlayerActor.tscn").instance()
	node.init()
	
	var coord = entity.components['location'].get_coord()
	var tile_location = Vector3(coord.get_x(), coord.get_y(), coord.get_z())
	var tile_offset = Utils.getScreenCoordsTileCenter(tile_location)
	
	node.entity_id = entity.id
	node.coords = tile_location
	node.position = Vector2(tile_offset.x, tile_offset.y)
	node.entity_name = entity.name
	
	var gid = entity.components['graphics'].get_graphics_id()
	var gtype = entity.components['graphics'].get_gtype()
	if gid == null:
		assert(false)
	else:
		node.load_animation(gid, gtype)
		
	return node
	
func createActorNode(entity):
	var node = load("res://game/actors/Actor.tscn").instance()
	node.init()
	
	var coord = entity.components['location'].get_coord()
	var tile_location = Vector3(coord.get_x(), coord.get_y(), coord.get_z())
	var tile_offset = Utils.getScreenCoordsTileCenter(tile_location)
	
	node.entity_id = entity.id
	node.coords = tile_location
	node.position = Vector2(tile_offset.x, tile_offset.y)
	node.entity_name = entity.name
	
	var gid = entity.components['graphics'].get_graphics_id()
	var gtype = entity.components['graphics'].get_gtype()
	if gid == null:
		assert(false)
	else:
		node.load_animation(gid, gtype)
		
	return node
	
func createGroundItemNode(entity, tile_location):
	var node = load("res://game/actors/GroundItem.tscn").instance()
	node.add_item_entity(entity)
	Utils.add_entity_location(entity, tile_location)
	var tile_offset = Utils.getScreenCoordsTileCenter(tile_location)
	node.position = Vector2(tile_offset.x, tile_offset.y)
	return node
	
func createObjectNode(entity):
	var node = load("res://game/actors/Object.tscn").instance()
	
	var coord = entity.components['location'].get_coord()
	var tile_location = Vector3(coord.get_x(), coord.get_y(), coord.get_z())
	var tile_offset = Utils.getScreenCoords(tile_location)
	
	node.entity_id = entity.id
	node.coords = tile_location
	node.position = Vector2(tile_offset.x, tile_offset.y)
	node.entity_name = entity.name
	
	if 'light' in entity.components:
		node.create_light(entity.components['light'].get_type())
	
	if 'graphics' in entity.components:
		var gid = entity.components['graphics'].get_graphics_id()
		var gtype = entity.components['graphics'].get_gtype()
		var cast_shadows = entity.components['graphics'].get_cast_shadows()
		if gid == null:
			assert(false)
		else:
			var direction = null
			if 'orientation' in entity.components:
				direction = entity.components['orientation'].get_direction()
			node.set_graphics(gid, gtype, cast_shadows, direction)
	else:
		node.hide()
	
	#TODO: make windows and other objects hanging on walls be displayed
	#on top of the upper wall tilemap
	if entity.name == 'Window':
		#node.z_as_relative = false
		#node.z_index = 11
		
		#This is the ugliest: remove top-wall tilemap cell in window location!
		var tmap_controller = GameEngine.context.world.world_map.tilemap_controller
		tmap_controller.dwelling_layer.tilemap_bottom.set_cell(tile_location[0], tile_location[1], 0, false, false, false, Vector2(6,0))
		
		pass
	
#	#bring sprite to the center + 16
#	var rect_size = node.get_node('Sprite').region_rect.size
#	node.position.x -= (rect_size.x/2 - 16)
#	node.position.y -= (rect_size.y - 64)
	
	var volume = null
	if 'volume' in entity.components:
		volume = entity.components['volume']
		#if it's a volume don't shift the sprite
	
	node.move_sprite_to_correct_location(volume)
	
	
	return node
