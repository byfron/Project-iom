extends Sprite

var frame_dictionary = {}
var frame_idx = 0
var num_frames_per_orient = 3

func load_spritesheet(anim_name, anim_meta, gid):
	texture = load(ResourceManager.get_char_diffuse_sprite_sheet(anim_name, gid))
	normal_map  = load(ResourceManager.get_char_normal_sprite_sheet(anim_name, gid))
	num_frames_per_orient = int(anim_meta['frames'])
	var directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']
	var fidx = 0
	for dir in directions:
		frame_dictionary[dir] = fidx
		fidx += num_frames_per_orient
		
	num_frames_per_orient = int(anim_meta['frames'])
	vframes = len(directions)
	hframes = num_frames_per_orient
	
func frame_forward(orientation):
	frame_idx += 1
	if frame_idx >= num_frames_per_orient:
		frame_idx = 0
	frame = frame_dictionary[orientation] + frame_idx

func set_frame_index(fidx, orientation):
	frame_idx = fidx
	self.frame = frame_dictionary[orientation] + frame_idx

func update_orientation(orientation):
	self.frame = frame_dictionary[orientation] + frame_idx
