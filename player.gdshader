shader_type canvas_item;

uniform float white_tint = 0.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.r = COLOR.r * (1.0 + white_tint);
	COLOR.g = COLOR.g * (1.0 + white_tint);
	COLOR.b = COLOR.b * (1.0 + white_tint);
}
