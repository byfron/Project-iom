shader_type canvas_item;

uniform bool frozen;
uniform vec4 outline_color; 
uniform float width : hint_range(0.0, 30.0);


void fragment() {
	vec4 col = vec4(texture(TEXTURE, UV));
	COLOR = col;
	
	if (frozen) {
		float factor = 0.75;
		vec4 fzcolor = factor * vec4(0.01, 0.94, 0.98, 1.0);
		COLOR = vec4(min(col.r + fzcolor.r, 1.0), min(col.g + fzcolor.g, 1.0), min(col.b + fzcolor.b, 1.0), col.a);
	}
}