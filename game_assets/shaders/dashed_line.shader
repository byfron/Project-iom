shader_type canvas_item;

void fragment() {
	float speed = 2.0;
	float time = fract(TIME) * speed;
	float stretch = 0.2;
	vec2 uv = UV;
	uv.x = mod(UV.x*stretch - time, 1);
	uv.y = mod(UV.y*stretch - time, 1);
	COLOR = texture(TEXTURE, uv);
	
}
