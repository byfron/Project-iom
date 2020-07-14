shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	if (color.a > 0.0) {
		color.r = 0.8;
		color.g = 0.8;
		color.b = 0.8;
	}
	
	COLOR = vec4(0);//color;
}