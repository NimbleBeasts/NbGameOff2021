shader_type canvas_item;
uniform float scroll_speed = 0.1;

void fragment() {
	vec2 newuv = UV;
	newuv.x += TIME*scroll_speed;
	COLOR = texture(TEXTURE, newuv);
}