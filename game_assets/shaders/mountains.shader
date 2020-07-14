shader_type canvas_item;
uniform sampler2D color_texture;
uniform float scale;
uniform vec2 uv_drag_offset;
render_mode blend_mix;
uniform vec4 border_color : hint_color;


void fragment() {
	
	vec2 waves_uv_offset;
	vec2 uv = vec2(SCREEN_UV.x * scale, SCREEN_UV.y * scale * 0.5);
	//waves_uv_offset.x = cos(TIME + uv.x + uv.y) * 0.02;
	//waves_uv_offset.y = sin(TIME + uv.x + uv.y) * 0.02;
	//uv += waves_uv_offset;
	
	uv += uv_drag_offset * 1.0;
	
	if (uv.x > 1.0) {
		uv.x -= float(int(uv.x));
	}
	if (uv.y > 1.0) {
		uv.y -= float(int(uv.y));
	}


	float border = texture(TEXTURE, UV).g;
	
	vec3 color = texture(color_texture, uv).rgb;
	float alpha = min(1.0, texture(TEXTURE, UV).a*1.2);
	COLOR.rgba = vec4(color*(1.0-border) + border_color.rgb*border, alpha);
}