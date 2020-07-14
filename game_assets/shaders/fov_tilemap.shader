shader_type canvas_item;
uniform vec4 shade_color : hint_color;


void fragment() {

	float alpha = 1.0 - texture(TEXTURE, UV).r;//min(0.25, texture(TEXTURE, UV).r);
	//float alpha = max(0.0, min(1.0, 1.0 - texture(TEXTURE, UV).a));
	COLOR.rgb = shade_color.rgb;
	COLOR.a = min(alpha, 0.8);
}