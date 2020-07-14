shader_type canvas_item;
uniform sampler2D mask_texture;
uniform float bar_percentage;
uniform vec4 color : hint_color;

void fragment() {
	vec2 uv = UV * vec2(3.0 * bar_percentage, 0.1);
	if (uv.x > 1.0) uv.x -= floor(uv.x);
	if (uv.y > 1.0) uv.y -= floor(uv.y);
	float cmix = 0.5;
    vec4 output_color = cmix * color + (1.0 - cmix) * color * (1.0 - texture(mask_texture, UV).r);//min(0.9,max(0.7,texture(mask_texture, uv).r));
    COLOR = output_color;
}