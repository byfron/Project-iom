shader_type canvas_item;

uniform bool selected;
uniform bool attacked;

void fragment() {
	vec4 col = vec4(texture(TEXTURE, UV));
	COLOR = col;
	if (selected) {
		float factor = 2.0;
		COLOR = vec4(min(col.r * factor, 1.0), min(col.g * factor, 1.0), min(col.b * factor, 1.0), col.a);
	}
	if (attacked) {
		COLOR = vec4(1.0, 1.0, 1.0, col.a);
	}
}