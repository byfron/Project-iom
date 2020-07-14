shader_type canvas_item;

uniform bool selected;
uniform bool attacked;

void fragment() {
	if (selected) {
		vec4 sprite_color = texture(TEXTURE, UV);
		float factor = 2.0;
		COLOR = vec4(min(sprite_color.r * factor, 1.0), min(sprite_color.g * factor, 1.0), min(sprite_color.b * factor, 1.0), sprite_color.a);
	} else {
		COLOR = vec4(texture(TEXTURE, UV));
	}
	
	if (attacked) {
		vec4 col = vec4(texture(TEXTURE, UV));
		COLOR = vec4(1.0, 1.0, 1.0, col.a);
	}
	else {
		COLOR = vec4(texture(TEXTURE, UV));
	}
}