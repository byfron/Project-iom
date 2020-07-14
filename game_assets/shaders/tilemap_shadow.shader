shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
	COLOR.a = min(0.35, color.a);
	COLOR.rgb = vec3(0,0,0);
}