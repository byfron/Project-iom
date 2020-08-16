shader_type canvas_item;

uniform bool selected;
uniform bool attacked;
uniform bool magic;
uniform bool frozen;
uniform bool glow;
uniform vec4 outline_color; 
uniform float width : hint_range(0.0, 30.0);

vec4 sample_glow_pixel(sampler2D tex, vec2 uv) {
    float hdr_threshold = 1.0; // Pixels with higher color than 1 will glow
    return max(texture(tex, uv) - hdr_threshold, vec4(0.0));
}


void fragment() {
	vec4 col = vec4(texture(TEXTURE, UV));
	COLOR = col;
	
	if (frozen) {
		float factor = 0.75;
		vec4 fzcolor = factor * vec4(0.01, 0.94, 0.98, 1.0);
		COLOR = vec4(min(col.r + fzcolor.r, 1.0), min(col.g + fzcolor.g, 1.0), min(col.b + fzcolor.b, 1.0), col.a);
	}
	else if (magic) {
		float sizex = width * 1.0 / float(textureSize(TEXTURE, 0).x);
		float sizey = width * 1.0 / float(textureSize(TEXTURE, 0).y);
		vec4 sprite_color = texture(TEXTURE, UV);
		//sprite_color.a = 0.0;
		float alpha = -8.0 * sprite_color.a;
		alpha += texture(TEXTURE, UV + vec2(0.0, -sizey)).a;
		alpha += texture(TEXTURE, UV + vec2(sizex, -sizey)).a;
		alpha += texture(TEXTURE, UV + vec2(sizex, 0.0)).a;
		alpha += texture(TEXTURE, UV + vec2(sizex, sizey)).a;
		alpha += texture(TEXTURE, UV + vec2(0.0, sizey)).a;
		alpha += texture(TEXTURE, UV + vec2(-sizex, sizey)).a;
		alpha += texture(TEXTURE, UV + vec2(-sizex, 0.0)).a;
		alpha += texture(TEXTURE, UV + vec2(-sizex, -sizey)).a;
		vec4 ocolor = outline_color;
		alpha = min(alpha, abs(sin(TIME * 5.0)));
		vec4 final_color = mix(sprite_color, ocolor, clamp(alpha, 0.0, 1.0));
		COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
		
		
		//float factor = 2.0;
		//COLOR = vec4(min(col.r * factor, 1.0), min(col.g * factor, 1.0), min(col.b * factor, 1.0), col.a);
	}
	else if (selected) {
		float factor = 2.0;
		COLOR = vec4(min(col.r * factor, 1.0), min(col.g * factor, 1.0), min(col.b * factor, 1.0), col.a);
	}
	else if (attacked) {
		COLOR = vec4(1.0, 1.0, 1.0, col.a);
	}
	
	if (glow) {
		vec2 ps = SCREEN_PIXEL_SIZE;
		vec4 col0 = sample_glow_pixel(TEXTURE, UV + vec2(-ps.x, 0));
    	vec4 col1 = sample_glow_pixel(TEXTURE, UV + vec2(ps.x, 0));
    	vec4 col2 = sample_glow_pixel(TEXTURE, UV + vec2(0, -ps.y));
    	vec4 col3 = sample_glow_pixel(TEXTURE, UV + vec2(0, ps.y));
    	vec4 color = texture(TEXTURE, UV);
    	vec4 glowing_col = 0.25 * (col0 + col1 + col2 + col3);
    	COLOR = vec4(color.rgb + glowing_col.rgb, color.a);
	}
	
}