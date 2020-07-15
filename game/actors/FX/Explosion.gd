extends Node2D

var objNode = load("res://game/actors/FX/ShatteredSprite.tscn"); var obj = []; var drops = [];
const height = 200; const width = 1024; var pos = Vector2(width * 0.5, height - 64)

var GRAVITY = 0.5; const DAMPING = 0.999
var timer = 0; var frames = 0; var detonate = false; var VoD = 1
var bits_x = 4
var bits_y = 4
var sprite_size_x = 29
var sprite_size_y = 40

class Fragmentation:
	var old; var new;
	var bounce_height = height
	func _init(arg1, arg2): 
		old = Vector2(arg1, arg2)
		new = old
		
	func integrate(delta): 
		var velocity = velocity()
		old = new
		new += velocity * DAMPING
		
	func velocity(): 
		return (new - old)
		
	func move(offset_x, offset_y): 
		new += Vector2(offset_x, offset_y)
		
	func bounce():
		if (new.y > bounce_height): 
			var velocity = velocity()
			old.y = bounce_height
			new.y = old.y - velocity.y * 0.3
			new.x = old.x
			
#			new.x = 0
		#if new.x < 0 or new.x > width: 
		#	new.x = 0
			
		return new

func initialize(texture, region_rect, bits_x, bits_y):
	pos = Vector2(0,0)
	sprite_size_x = region_rect.size.x
	sprite_size_y = region_rect.size.y
	var n = 0
	for i in range(bits_x):
		for j in range(bits_y):
			var sprite = Sprite.new()
			sprite.texture = texture
			sprite.region_enabled = true
			sprite.region_rect.position.x = float(i*(region_rect.size.x))/bits_x + region_rect.position.x
			sprite.region_rect.position.y = float(j*(region_rect.size.y))/bits_y + region_rect.position.y
			sprite.region_rect.size.x = region_rect.size.x/bits_x
			sprite.region_rect.size.y = region_rect.size.y/bits_y
			obj.append(sprite)
			obj[n].set_frame(n)
			add_child(obj[n])
			n+=1
			
	for y in range(bits_y):
		for x in range(bits_x):
			obj[frames].set_position(Vector2(x * (sprite_size_x/bits_x) + pos.x, y*(sprite_size_y/bits_y) + pos.y))
			frames += 1

	obj.shuffle()

func img():
	pos = Vector2(0,0)
		
	for n in range(bits_x*bits_y):
		obj.append(objNode.instance())
		obj[n].set_frame(n);
		add_child(obj[n])
		
	for y in range(bits_y):
		for x in range(bits_x):
			obj[frames].set_position(Vector2(x * (sprite_size_x/bits_x) + pos.x, y*(sprite_size_y/bits_y) + pos.y))
			frames += 1
			
	obj.shuffle()
			
func clear():
	frames = 0
	for n in range(len(obj)):
		remove_child(obj[n])
	obj.clear()
		
func explosion(delta):
	if detonate == true:
		for j in range(VoD):
			if drops.size() < obj.size():
				var n = drops.size()
				var drop = Fragmentation.new(obj[n].get_position().x, obj[n].get_position().y)
				
				drop.bounce_height = pos.y + rand_range(0, 40)
				
				#drop.move(randf()*4 -2, randf()*(-2)-15)
				#drop.move((randf()*10 - 5), (randf()*(-6.0)-10))
				drop.move((randf()*4 - 2), (randf()*(-5.0)-10))
				drops.push_front(drop)
				
			#randomize drop order
			#drops.shuffle()
			
			for i in range(drops.size()):
				drops[i].move(0, GRAVITY)
				drops[i].integrate(1)
				obj[i].set_position(Vector2(drops[i].bounce().x, drops[i].bounce().y))
				if obj[i].get_position().x > pos.x:
					obj[i].rotate(rand_range(-0.5, -2.5))
				if obj[i].get_position().x < pos.x:
					obj[i].rotate(rand_range(0.5, 2.5))
				if obj[i].get_position().y >= pos.y:
					obj[i].set_rotation(0.1)
			timer += 1 
			
			#reduce opacity with time
			if timer > 40:
				self.modulate.a = max(0, (80 - timer)/100.0)
			
			if drops.size() == obj.size() and timer > 100:
				drops.clear()
				clear()
				#img()
				timer = 0
				detonate = false
				
func _ready():
	set_process_input(true)
	set_process(true)
	
func _process(delta):
	explosion(delta)

func _input(event):
	if Input.is_key_pressed(KEY_SPACE): detonate = true


