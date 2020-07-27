shader_type canvas_item;

uniform bool selected;
uniform bool attacked;
uniform bool magic;
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
}