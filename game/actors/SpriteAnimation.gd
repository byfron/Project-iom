extends Sprite

var frame_dictionary = {}
var frame_idx = 0
var num_frames_per_orient = 3
var directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']

func load_spritesheet(tex, nmap, anim_meta):
	texture = tex
	normal_map = nmap
	num_frames_per_orient = int(anim_meta['frames'])
	var fidx = 0
	for dir in directions:
		frame_dictionary[dir] = fidx
		fidx += num_frames_per_orient
		
	num_frames_per_orient = int(anim_meta['frames'])
	vframes = len(directions)
	hframes = num_frames_per_orient
	if num_frames_per_orient == 10:
		pass
	
func frame_forward(orientation):
	frame_idx += 1
	if frame_idx >= num_frames_per_orient:
		frame_idx = 0
	frame = frame_dictionary[orientation] + frame_idx
	
	print(frame_idx)

func set_frame_index(fidx, orientation):
	frame_idx = fidx
	self.frame = frame_dictionary[orientation] + frame_idx

func update_orientation(orientation):
	self.frame = frame_dictionary[orientation] + frame_idx
