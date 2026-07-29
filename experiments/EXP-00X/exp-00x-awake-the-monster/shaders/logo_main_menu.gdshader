shader_type canvas_item;

uniform float custom_time = 0.0;
uniform float breath_speed : hint_range(0.0, 1.0) = 0.12;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float glow_size : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec4 modulate = COLOR;
	vec4 color = texture(TEXTURE, UV);
	float breath = sin(custom_time * breath_speed) * 0.5 + 0.5;

	float glow = 0.0;
	for (int i = 0; i < 8; i++) {
		vec2 offset = vec2(
			sin(float(i) * 1.57) * glow_size,
			cos(float(i) * 1.57) * glow_size
		);
		glow += texture(TEXTURE, UV + offset * (1.0 + breath * 0.5)).a;
	}
	glow = glow / 8.0;

	color.rgb = color.rgb * (1.0 + glow * glow_intensity * breath);
	color.a = color.a * mix(0.75, 1.0, breath);

	COLOR = color * modulate;
}
