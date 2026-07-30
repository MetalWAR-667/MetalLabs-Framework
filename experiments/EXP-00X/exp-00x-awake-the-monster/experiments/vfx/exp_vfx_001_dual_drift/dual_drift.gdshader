shader_type canvas_item;
render_mode unshaded;

uniform sampler2D source_a : repeat_enable, filter_linear;
uniform sampler2D source_b : repeat_enable, filter_linear;

uniform vec2 direction_a = vec2(1.0, 0.18);
uniform vec2 direction_b = vec2(-0.35, 1.0);
uniform float speed_a : hint_range(0.0, 0.1, 0.001) = 0.008;
uniform float speed_b : hint_range(0.0, 0.1, 0.001) = 0.005;
uniform float scale_a : hint_range(0.25, 8.0, 0.05) = 1.15;
uniform float scale_b : hint_range(0.25, 8.0, 0.05) = 1.65;

uniform float opacity : hint_range(0.0, 1.0, 0.01) = 0.62;
uniform float contrast : hint_range(0.25, 4.0, 0.05) = 1.35;
uniform float threshold : hint_range(0.0, 1.0, 0.01) = 0.42;
uniform vec4 fog_tint : source_color = vec4(0.28, 0.36, 0.44, 1.0);
uniform vec4 void_color : source_color = vec4(0.012, 0.022, 0.04, 1.0);
uniform int combination_mode : hint_enum("Multiply,Minimum,Average,Maximum") = 2;

float combine_sources(float a, float b) {
	if (combination_mode == 0) {
		return a * b;
	}
	if (combination_mode == 1) {
		return min(a, b);
	}
	if (combination_mode == 3) {
		return max(a, b);
	}
	return (a + b) * 0.5;
}

void fragment() {
	// Keep spatial scale consistent in the fixed 16:9 laboratory viewport.
	vec2 aspect_uv = (UV - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	vec2 uv_a = aspect_uv * scale_a + direction_a * speed_a * TIME;
	vec2 uv_b = aspect_uv * scale_b + direction_b * speed_b * TIME;

	float noise_a = texture(source_a, uv_a).r;
	float noise_b = texture(source_b, uv_b).r;
	float combined = combine_sources(noise_a, noise_b);

	float shaped = clamp((combined - threshold) * contrast + 0.5, 0.0, 1.0);
	shaped = smoothstep(0.0, 1.0, shaped);
	vec3 color = mix(void_color.rgb, fog_tint.rgb, shaped * opacity);
	COLOR = vec4(color, 1.0);
}
