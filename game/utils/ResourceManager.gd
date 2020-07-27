extends Node
var _char_sprite_sheet_dict = {}
var _char_anim_type_dict = {}
var _char_object_sprite_sheet_dict = {}
var _char_object_anim_type_dict = {}
var _fx_sprite_sheet_dict = {}
var _fx_anim_type_dict = {}
var _item_sprite_sheet_dict = {}
var _item_anim_type_dict = {}

var _object_sprite_meta = {}
var _item_sprite_meta_32x32 = {}
var _item_icon_meta = {}

func load_sound_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)

func load_fx_animation_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)
	for sheet_cfg in metadata['SpriteSheets']:
		var gid = int(sheet_cfg['gid'])
		_fx_sprite_sheet_dict[gid] = sheet_cfg['sprite_sheet']

	for anim_type in metadata['AnimationTypes']:
		var gtype = int(anim_type['gtype'])
		_fx_anim_type_dict[gtype] = anim_type['anims']
		
func load_char_object_animation_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)
	for sheet_cfg in metadata['SpriteSheets']:
		var gid = int(sheet_cfg['gid'])
		_char_object_sprite_sheet_dict[gid] = sheet_cfg['sprite_sheet']

	for anim_type in metadata['AnimationTypes']:
		var gtype = int(anim_type['gtype'])
		_char_object_anim_type_dict[gtype] = anim_type['anims']
		
func load_char_animation_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)
	for sheet_cfg in metadata['SpriteSheets']:
		var gid = int(sheet_cfg['gid'])
		_char_sprite_sheet_dict[gid] = sheet_cfg['sprite_sheet']

	for anim_type in metadata['AnimationTypes']:
		var gtype = int(anim_type['gtype'])
		_char_anim_type_dict[gtype] = anim_type['anims']

func load_item_animation_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)
		
	for sheet_cfg in metadata['SpriteSheets']:
		var gid = int(sheet_cfg['gid'])
		_item_sprite_sheet_dict[gid] =  "res://resources/sprite_sheets/" + sheet_cfg['sprite_sheet']
		
	for anim_type in metadata['AnimationTypes']:
		var gtype = int(anim_type['gtype'])
		_item_anim_type_dict[gtype] = anim_type['anims']

func get_char_object_sprite_sheet(gid):
	return _char_object_sprite_sheet_dict[gid]
	
func get_fx_sprite_sheet(gid):
	return _fx_sprite_sheet_dict[gid]
		
func get_char_sprite_sheet(gid):
	return _char_sprite_sheet_dict[gid]
	
func get_item_sprite_sheet(gid):
	return _item_sprite_sheet_dict[gid]
	
func get_item_icon_sprite(item_type):
	var icon_path = "res://game_assets/gui/icons/items/"
	return icon_path + _item_icon_meta[int(item_type)] + '.png'
	
func load_item_icon_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)
	for item_meta in metadata["ItemIcons"]:
		_item_icon_meta[int(item_meta['item_type'])] = item_meta['icon']
	
func load_item_sprite_metadata():
	var item_path = "res://game_assets/textures/objects"
	var metadata = Utils.load_from_json(item_path + '/items_sheet_meta_32x32.json')
	for gid_entry in metadata['items']:
		var gid = int(gid_entry)
		_item_sprite_meta_32x32[gid] = metadata['items'][gid_entry]
		
func load_object_sheet(metadata, size_str):
	for gid in metadata['objects']:
		_object_sprite_meta[gid] = {
			'coords': metadata['objects'][gid],
			'size': metadata['size'],
			'texture': 'objects_sheet_' + size_str + '.png'
		}
		
func load_object_sprite_metadata():
	var object_path = "res://game_assets/textures/objects"
	var metadata = Utils.load_from_json(object_path + '/object_sheet_meta_32x64.json')
	load_object_sheet(metadata, '32x64')
	metadata = Utils.load_from_json(object_path + '/object_sheet_meta_96x128.json')
	load_object_sheet(metadata, '96x128')
	metadata = Utils.load_from_json(object_path + '/object_sheet_meta_96x64.json')
	load_object_sheet(metadata, '96x64')
	metadata = Utils.load_from_json(object_path + '/object_sheet_meta_32x96.json')
	load_object_sheet(metadata, '32x96')
	
func get_object_sprite_sheet():
	pass

func get_fx_diffuse_sprite_sheet(anim_name, gid):
	var sprite_sheet = ResourceManager.get_fx_sprite_sheet(gid)
	var texture_file = 'res://game_assets/textures/FX/' + sprite_sheet + '/DIFFUSE_' + sprite_sheet + '_' + anim_name + '_sheet.png'
	return texture_file
	
func get_char_object_diffuse_sprite_sheet(anim_name, gid):
	var sprite_sheet = ResourceManager.get_char_object_sprite_sheet(gid)
	var texture_file = 'res://game_assets/textures/character_objects/' + sprite_sheet + '/DIFFUSE_' + sprite_sheet + '_' + anim_name + '_sheet.png'
	return texture_file
	
func get_char_diffuse_sprite_sheet(anim_name, gid):
	var sprite_sheet = ResourceManager.get_char_sprite_sheet(gid)
	var texture_file = 'res://game_assets/textures/characters/' + sprite_sheet + '/DIFFUSE_' + sprite_sheet + '_' + anim_name + '_sheet.png'
	return texture_file
	
func get_char_normal_sprite_sheet(anim_name, gid):
	var sprite_sheet = ResourceManager.get_char_sprite_sheet(gid)
	var texture_file = 'res://game_assets/textures/characters/' + sprite_sheet + 'NORMAL_' + sprite_sheet + '_' + anim_name + '_sheet.png'
	return texture_file
	
func get_char_anim_metadata(gtype):
	return _char_anim_type_dict[gtype]

func get_char_object_anim_metadata(gtype):
	return _char_object_anim_type_dict[gtype]

func get_fx_anim_metadata(gtype):
	return _fx_anim_type_dict[gtype]

func get_item_anim_metadata(gtype):
	return _item_anim_type_dict[gtype]
