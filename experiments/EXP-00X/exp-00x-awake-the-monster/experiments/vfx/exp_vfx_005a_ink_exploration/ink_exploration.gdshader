shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ink_source : repeat_enable, filter_linear;
uniform int observation_mode : hint_enum("Base Source,Ink Mask,Composite") = 2;

uniform float ink_amount : hint_range(0.0, 1.0, 0.01) = 0.55;
uniform float ink_threshold : hint_range(0.0, 1.0, 0.01) = 0.52;
uniform float ink_contrast : hint_range(0.5, 4.0, 0.05) = 1.8;
uniform float edge_width : hint_range(0.005, 0.2, 0.005) = 0.06;
uniform float spread : hint_range(0.0, 0.25, 0.005) = 0.08;
uniform float spread_speed : hint_range(0.0, 0.5, 0.005) = 0.12;
uniform float flow_distortion : hint_range(0.0, 0.3, 0.005) = 0.08;
uniform float flow_scale : hint_range(0.25, 4.0, 0.05) = 1.7;
uniform float dark_core : hint_range(0.0, 1.0, 0.01) = 0.78;
uniform float diffusion_halo : hint_range(0.0, 1.0, 0.01) = 0.34;
uniform float temporal_drift : hint_range(0.0, 0.1, 0.001) = 0.015;
uniform vec4 ink_color : source_color = vec4(0.018, 0.022, 0.028, 1.0);
uniform vec4 paper_color : source_color = vec4(0.72, 0.70, 0.65, 1.0);

void fragment() {
	vec2 aspect_uv = (UV - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	float time = TIME * temporal_drift;

	// Two offset reads of the same source create slow deformation without
	// introducing a second texture or a procedural noise system.
	vec2 flow_uv = aspect_uv * flow_scale;
	float flow_x = texture(ink_source, flow_uv + vec2(time, -time * 0.37)).r;
	float flow_y = texture(ink_source, flow_uv + vec2(0.43 - time * 0.29, time * 0.61)).r;
	vec2 distortion = (vec2(flow_x, flow_y) - vec2(0.5)) * flow_distortion;

	vec2 ink_uv = aspect_uv * 0.82 + distortion;
	float source_value = texture(ink_source, ink_uv).r;
	source_value = clamp((source_value - 0.5) * ink_contrast + 0.5, 0.0, 1.0);

	float threshold_motion = sin(TIME * spread_speed) * spread;
	float animated_threshold = ink_threshold - (ink_amount - 0.5) * 0.35 + threshold_motion;
	float body = smoothstep(
		animated_threshold - edge_width,
		animated_threshold + edge_width,
		source_value
	);
	float core = smoothstep(
		animated_threshold + edge_width * 0.35,
		animated_threshold + edge_width * 2.2,
		source_value
	);
	float halo_outer = smoothstep(
		animated_threshold - edge_width * 4.0,
		animated_threshold - edge_width * 0.5,
		source_value
	);
	float halo = max(halo_outer - body, 0.0) * diffusion_halo;

	if (observation_mode == 0) {
		COLOR = vec4(vec3(source_value), 1.0);
	} else if (observation_mode == 1) {
		COLOR = vec4(vec3(body), 1.0);
	} else {
		float body_density = body * (0.62 + dark_core * 0.20);
		float core_density = core * dark_core;
		float total_density = clamp(halo * 0.28 + body_density + core_density, 0.0, 1.0);
		vec3 color = mix(paper_color.rgb, ink_color.rgb, total_density);
		COLOR = vec4(color, 1.0);
	}
}
