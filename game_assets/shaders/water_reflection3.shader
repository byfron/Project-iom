shader_type canvas_item;
uniform vec4 color : hint_color;

void fragment() {
	float texture_h = 224.0;
	float screen_h = 1000.0;
	float sprite_uv_h = (32.0) / screen_h;
	
	float pixels_height = texture_h * UV.y;
	float pixels_width = texture_h * UV.x;
	
	float tile_uv_y = float(int(pixels_height) % 32)/32.0 + 0.01;
	float tile_uv_x = float(int(pixels_width) % 32)/32.0;
    vec2 tile_uv = vec2(tile_uv_x, tile_uv_y);
	
	vec2 uv = vec2(SCREEN_UV.x, SCREEN_UV.y + 2.0 * sprite_uv_h + sprite_uv_h * tile_uv.y * 2.0);
	float alpha = texture(TEXTURE, UV).a;
	vec3 c = texture(SCREEN_TEXTURE, uv).rgb;
	COLOR.rgb = color.rgb;
	COLOR.a = alpha;
	
}