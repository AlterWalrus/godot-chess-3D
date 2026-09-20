shader_type canvas_item;

uniform float invert_factor = 0.0;

void fragment() {
	vec4 color = COLOR;
	COLOR = vec4(abs(invert_factor - color.rgb), color.a);
}
