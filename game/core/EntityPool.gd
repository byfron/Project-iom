extends Node
onready var ECS = preload('res://game/core/proto/ecs.gd')
onready var Entity = load('res://game/core/Entity.gd')

var eindex = {}
var cindex = {}
var component_actions = {}
var action_map = {}

func get_actions(entity):
	var actions = []
	for comp in entity.components:
		for ac in get_component_actions(comp):
			actions.append(ac)
			
	return actions
	
func get_component_actions(comp_name):
	if comp_name in component_actions:
		return component_actions[comp_name]
	else:
		 return []
	
func get_entities():
	return eindex

func filter(component):
	if component in cindex:
		return cindex[component]
	else:
		return []
		
func get(eid):
	if eid in eindex:
		return eindex[eid]
	else:
		 return null

func decode_component(ctype, comp_data):
	var comp = null
	
	#TODO: we may be able to dynamically construct the method call
	if ctype == 'location':
		comp = ECS.LocationComponent.new()
	elif ctype == 'movement':
		comp = ECS.MovementComponent.new()
	elif ctype == 'character':
		comp = ECS.CharacterComponent.new()
	elif ctype == 'initiative':
		comp = ECS.InitiativeComponent.new()
	elif ctype == 'description':
		comp = ECS.DescriptionComponent.new()
	elif ctype == 'graphics':
		comp = ECS.GraphicsComponent.new()
	elif ctype == 'chunk':
		comp = ECS.ChunkComponent.new()
	elif ctype == 'door':
		comp = ECS.DoorComponent.new()
	elif ctype == 'container':
		comp = ECS.ContainerComponent.new()
	elif ctype == 'item':
		comp = ECS.ItemComponent.new()
	elif ctype == 'main_character':
		comp = ECS.MainCharacterComponent.new()
	elif ctype == 'behavior':
		comp = ECS.BehaviorComponent.new()
	elif ctype == 'dialog':
		comp = ECS.DialogComponent.new()
	elif ctype == 'light':
		comp = ECS.LightComponent.new()
	elif ctype == 'weapon':
		comp = ECS.WeaponComponent.new()
	elif ctype == 'inventory':
		comp = ECS.InventoryComponent.new()
	elif ctype == 'food':
		comp = ECS.FoodComponent.new()
	elif ctype == 'stairs':
		comp = ECS.StairsComponent.new()
	elif ctype == 'skills':
		comp = ECS.SkillsComponent.new()
	elif ctype == 'char_stats':
		comp = ECS.CharStatsComponent.new()
	elif ctype == 'sound':
		comp = ECS.SoundComponent.new()
	elif ctype == 'fire':
		comp = ECS.FireComponent.new()
	elif ctype == 'throwable':
		comp = ECS.ThrowableComponent.new()
	elif ctype == 'char_status':
		comp = ECS.CharStatusComponent.new()
	elif ctype == 'volume':
		comp = ECS.VolumeComponent.new()
	elif ctype == 'orientation':
		comp = ECS.OrientationComponent.new()
	elif ctype == 'interest':
		comp = ECS.InterestComponent.new()		
	if comp:
		comp.from_bytes(Marshalls.base64_to_raw(comp_data.get_string_from_utf8()))
	else:
		assert(false)
		
	return comp

func load_pool(filename):
	var f = File.new()
	f.open(filename, File.READ)
	var content = f.get_as_text()
	f.close()
	var entity_pool = ECS.PBEntityPool.new()
	entity_pool.from_bytes(Marshalls.base64_to_raw(content))
	var ent_map = entity_pool.get_entities()	
	
	for ent_id in ent_map:
		var entity_data = ent_map[ent_id]
		var entity = Entity.new(ent_id, entity_data.get_name())
		for comp in entity_data.get_components():
			var type = comp.get_type()
			var component = decode_component(type, comp.get_data())
			entity.attach(type, component)
			
	var actions = entity_pool.get_actions()
	for action in actions:
		
		action_map[action.get_action_id()] = action
		
		var comp_names = action.get_component_type()
		for comp_name in comp_names:
			if comp_name in component_actions:
				component_actions[comp_name].append(action)
			else:
				component_actions[comp_name] = [action]
