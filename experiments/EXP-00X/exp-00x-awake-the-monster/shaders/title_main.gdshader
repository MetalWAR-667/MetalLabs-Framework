shader_type canvas_item;

uniform float custom_time = 0.0;
uniform float breath_speed : hint_range(0.0, 1.0) = 0.12;
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.35;
uniform vec4 tint_indigo : source_color = vec4(0.1019608, 0.0823529, 0.1568627, 1.0);
uniform float wave_amplitude : hint_range(0.0, 0.02) = 0.004;
uniform float wave_frequency : hint_range(0.0, 20.0) = 6.0;
uniform float wave_speed : hint_range(0.0, 2.0) = 0.4;

void fragment() {
	vec4 modulate = COLOR;
	vec2 wave_uv = UV;
	wave_uv.x += sin(UV.y * wave_frequency + custom_time * wave_speed) * wave_amplitude;
	vec4 color = texture(TEXTURE, wave_uv);
	float breath = sin(custom_time * breath_speed) * 0.5 + 0.5;

	float edge = 1.0 - smoothstep(0.0, 0.4, min(UV.x, 1.0 - UV.x));
	edge *= 1.0 - smoothstep(0.0, 0.4, min(UV.y, 1.0 - UV.y));
	float glow = edge * breath * glow_intensity;

	color.rgb += glow * color.rgb;
	color.rgb = mix(color.rgb, color.rgb * (vec3(1.0) - tint_indigo.rgb * 0.4), 0.25);
	color.a *= mix(0.85, 1.0, breath);

	COLOR = color * modulate;
}
