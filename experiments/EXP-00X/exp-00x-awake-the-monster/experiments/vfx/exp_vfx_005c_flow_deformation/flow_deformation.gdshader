shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ink_source : repeat_enable, filter_linear;
uniform int observation_mode : hint_enum("Base Source,Ink Mask,Composite,Deformed Source") = 2;

uniform float ink_amount = 0.55;
uniform float ink_threshold = 0.52;
uniform float ink_contrast = 1.8;
uniform float edge_width = 0.06;
uniform float spread = 0.08;
uniform float spread_speed = 0.12;
uniform float flow_distortion = 0.08;
uniform float flow_scale = 1.7;
uniform float dark_core = 0.78;
uniform float diffusion_halo = 0.34;
uniform float temporal_drift = 0.015;
uniform vec4 ink_color : source_color = vec4(0.018, 0.022, 0.028, 1.0);
uniform vec4 paper_color : source_color = vec4(0.72, 0.70, 0.65, 1.0);

uniform float twist_strength = 1.15;
uniform float twist_radius = 0.82;
uniform vec2 twist_center = vec2(0.43, 0.56);
uniform float twist_speed = 0.025;

vec2 apply_local_twist(vec2 position) {
	vec2 center = (twist_center - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	vec2 local = position - center;
	float distance_to_center = length(local);
	float radius = max(twist_radius, 0.01);
	float influence = 1.0 - smoothstep(radius * 0.12, radius, distance_to_center);

	// A small temporal variation changes the fold without spinning the complete
	// image at a constant angular velocity.
	float temporal_fold = 0.90 + 0.10 * sin(
		TIME * twist_speed + distance_to_center * 4.7
	);
	float angle = twist_strength * influence * temporal_fold;
	float sine_angle = sin(angle);
	float cosine_angle = cos(angle);
	vec2 rotated = vec2(
		local.x * cosine_angle - local.y * sine_angle,
		local.x * sine_angle + local.y * cosine_angle
	);
	return center + rotated;
}

void fragment() {
	vec2 aspect_uv = (UV - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	float time = TIME * temporal_drift;
	vec2 twisted_uv = apply_local_twist(aspect_uv);

	vec2 flow_uv = twisted_uv * flow_scale;
	float region_a = texture(ink_source, flow_uv + vec2(time, -time * 0.31)).r;
	float region_b = texture(ink_source, flow_uv + vec2(0.37 - time * 0.23, time * 0.53)).r;
	vec2 distortion = (vec2(region_a, region_b) - vec2(0.5)) * flow_distortion;

	vec2 ink_uv = twisted_uv * 0.82 + distortion;
	float source_value = texture(ink_source, ink_uv).r;
	source_value = clamp((source_value - 0.5) * ink_contrast + 0.5, 0.0, 1.0);

	float regional_phase = region_a * 6.2831853 + region_b * 2.7;
	float local_expansion = sin(regional_phase + TIME * spread_speed * 0.22) * spread;
	float edge_perturbation = (region_b - 0.5) * edge_width * 0.7;
	float animated_threshold = (
		ink_threshold
		- (ink_amount - 0.5) * 0.35
		+ local_expansion
		+ edge_perturbation
	);

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
		float original = texture(ink_source, aspect_uv * 0.82).r;
		original = clamp((original - 0.5) * ink_contrast + 0.5, 0.0, 1.0);
		COLOR = vec4(vec3(original), 1.0);
	} else if (observation_mode == 1) {
		COLOR = vec4(vec3(body), 1.0);
	} else if (observation_mode == 3) {
		COLOR = vec4(vec3(source_value), 1.0);
	} else {
		float body_density = body * (0.62 + dark_core * 0.20);
		float core_density = core * dark_core;
		float total_density = clamp(halo * 0.28 + body_density + core_density, 0.0, 1.0);
		COLOR = vec4(mix(paper_color.rgb, ink_color.rgb, total_density), 1.0);
	}
}
