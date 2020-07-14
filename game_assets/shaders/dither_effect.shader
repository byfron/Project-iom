// Based on http://devlog-martinsh.blogspot.com/2011/03/glsl-dithering.html

shader_type canvas_item;

void fragment() {
  vec2 texCoord = SCREEN_UV;

  vec4 lum = vec4(0.299, 0.587, 0.114, 0.0);
  float grayscale = dot(texture(SCREEN_TEXTURE, texCoord), lum);
  vec4 color = texture(SCREEN_TEXTURE, texCoord);

  vec2 xy = FRAGCOORD.xy;
  float x = mod(xy.x, 4.0);
  float y = mod(xy.y, 4.0);

  COLOR = dither8x8_rgba(vec2(x, y), color);
  //COLOR.r = find_closest(x, y, rgb.r);
  //COLOR.g = find_closest(x, y, rgb.g);
  //COLOR.b = find_closest(x, y, rgb.b);
}