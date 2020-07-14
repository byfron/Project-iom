shader_type canvas_item;

uniform bool selected;
uniform bool sinking;

uniform float width : hint_range(0.0, 30.0);
uniform vec4 outline_color; 
uniform sampler2D sink_mask;

void fragment() {
	
		
	if (selected) 
	{		
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
		vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
		COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	} else {
		COLOR = vec4(texture(TEXTURE, UV));
	}
	
	if (sinking) {
		
		float sizex = float(textureSize(TEXTURE, 0).x);
		float sizey = float(textureSize(TEXTURE, 0).y);
		float xpix = sizex * UV.x;
		float ypix = sizey * UV.y;
		
		//vec2 mask_coords = vec2(xpix/64.0 - float(int(xpix)%64), ypix/64.0 - float(int(ypix)%64));
		vec2 mask_coords = vec2(xpix/64.0 - float(int(xpix)/64), (ypix/64.0  - float(int(ypix)/64)));
		
		//mask sprite with SinkMask texture
		vec4 mask_value = vec4(texture(sink_mask, mask_coords));
		COLOR = vec4(texture(TEXTURE, UV));
		COLOR.a = (1.0 - mask_value.a) * COLOR.a;
	}
	
}