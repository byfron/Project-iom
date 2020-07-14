shader_type canvas_item;

uniform vec4 color;

void fragment() {
	vec2 uv = UV;
	COLOR = vec4(uv.x, uv.y, 1.0, 1.0);
	COLOR = color;
}