shader_type canvas_item;

void fragment() {
    vec4 colour = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (colour.x == 1.0 && colour.y == 0.0 && colour.z == 1.0) {
		COLOR = vec4(0,0,0,0);
	}
	else COLOR = texture(TEXTURE, UV);
}