extends Node
var _char_sprite_sheet_dict = {}
var _char_anim_type_dict = {}
var _item_sprite_sheet_dict = {}
var _item_anim_type_dict = {}

var _object_sprite_meta = {}
var _item_sprite_meta_32x32 = {}
var _item_icon_meta = {}

func load_sound_metadata(json_file):
	var metadata = Utils.load_from_json(json_file)

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
		
func load_object_sprite_metadata():
	var object_path = "res://game_assets/textures/objects"
	var metadata = Utils.load_from_json(object_path + '/object_sheet_meta_32x64.json')
	for gid_entry in metadata['objects']:
		var gid = int(gid_entry)
		_object_sprite_meta[gid] = {
			'coords': metadata['objects'][gid_entry],
			'size': metadata['size'],
			'texture': 'objects_sheet_32x64.png'
		}
		
	metadata = Utils.load_from_json(object_path + '/object_sheet_meta_96x128.json')
	for gid_entry in metadata['objects']:
		var gid = int(gid_entry)
		_object_sprite_meta[gid] = {
			'coords': metadata['objects'][gid_entry],
			'size': metadata['size'],
			'texture': 'objects_sheet_96x128.png'
		}
		
	metadata = Utils.load_from_json(object_path + '/object_sheet_meta_32x96.json')
	for gid_entry in metadata['objects']:
		var gid = int(gid_entry)
		_object_sprite_meta[gid] = {
			'coords': metadata['objects'][gid_entry],
			'size': metadata['size'],
			'texture': 'objects_sheet_32x96.png'
		}
	
func get_object_sprite_sheet():
	pass
	
func get_char_diffuse_sprite_sheet(anim_name, gid):
	var sprite_sheet = ResourceManager.get_char_sprite_sheet(gid)
	var texture_file = 'res://game_assets/textures/characters/DIFFUSE_' + sprite_sheet + '_' + anim_name + '_sheet.png'
	return texture_file
	
func get_char_normal_sprite_sheet(anim_name, gid):
	var sprite_sheet = ResourceManager.get_char_sprite_sheet(gid)
	var texture_file = 'res://game_assets/textures/characters/NORMAL_' + sprite_sheet + '_' + anim_name + '_sheet.png'
	return texture_file
	
func get_char_anim_metadata(gtype):
	return _char_anim_type_dict[gtype]

func get_item_anim_metadata(gtype):
	return _item_anim_type_dict[gtype]
