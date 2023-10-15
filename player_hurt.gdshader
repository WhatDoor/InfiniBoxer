shader_type canvas_item;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.r = COLOR.r + 0.5;
	COLOR.b = COLOR.b;
}
