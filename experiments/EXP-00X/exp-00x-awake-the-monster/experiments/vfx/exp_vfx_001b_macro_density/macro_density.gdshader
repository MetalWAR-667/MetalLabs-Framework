shader_type canvas_item;
render_mode unshaded;

uniform sampler2D source_a : repeat_enable, filter_linear;
uniform sampler2D source_b : repeat_enable, filter_linear;
uniform sampler2D macro_source : repeat_enable, filter_linear;

uniform vec2 direction_a = vec2(1.0, 0.18);
uniform vec2 direction_b = vec2(-0.35, 1.0);
uniform float speed_a = 0.008;
uniform float speed_b = 0.005;
uniform float scale_a = 1.15;
uniform float scale_b = 1.65;
uniform float opacity = 0.62;
uniform float contrast = 1.35;
uniform float threshold = 0.42;
uniform vec4 fog_tint : source_color = vec4(0.28, 0.36, 0.44, 1.0);
uniform vec4 void_color : source_color = vec4(0.012, 0.022, 0.04, 1.0);
uniform int combination_mode : hint_enum("Multiply,Minimum,Average,Maximum") = 2;

uniform bool macro_enabled = true;
uniform float macro_scale : hint_range(0.05, 1.0, 0.01) = 0.32;
uniform float macro_speed : hint_range(0.0, 0.02, 0.0001) = 0.001;
uniform float macro_influence : hint_range(0.0, 1.0, 0.01) = 0.55;
uniform float macro_contrast : hint_range(0.25, 3.0, 0.05) = 1.0;

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
	vec2 aspect_uv = (UV - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	vec2 uv_a = aspect_uv * scale_a + direction_a * speed_a * TIME;
	vec2 uv_b = aspect_uv * scale_b + direction_b * speed_b * TIME;

	float a = texture(source_a, uv_a).r;
	float b = texture(source_b, uv_b).r;
	float fog = clamp((combine_sources(a, b) - threshold) * contrast + 0.5, 0.0, 1.0);
	fog = smoothstep(0.0, 1.0, fog);

	if (macro_enabled) {
		vec2 macro_uv = aspect_uv * macro_scale;
		macro_uv += vec2(0.31, -0.17) * macro_speed * TIME;
		float macro_mask = texture(macro_source, macro_uv).r;
		macro_mask = clamp((macro_mask - 0.5) * macro_contrast + 0.5, 0.0, 1.0);
		macro_mask = smoothstep(0.0, 1.0, macro_mask);
		fog *= mix(1.0, macro_mask, macro_influence);
	}

	vec3 color = mix(void_color.rgb, fog_tint.rgb, fog * opacity);
	COLOR = vec4(color, 1.0);
}
