shader_type canvas_item;
render_mode unshaded;

// DREAM FOG
// Overall opacity and presence of the procedural mist.
uniform float fog_density : hint_range(0.0, 1.0) = 0.28;
// Drift speed of the fog. Small values preserve the dreamlike pace.
uniform float fog_speed : hint_range(0.0, 1.0) = 0.035;
// Size of the fog structures. Lower values produce broader masses.
uniform float fog_scale : hint_range(0.5, 8.0) = 2.4;

// SWIRL AND SPACE DISTORTION
// Strength of the local bend around the centre of the screen.
uniform float swirl_strength : hint_range(0.0, 2.0) = 0.0;
// Normalized radius affected by the swirl.
uniform float swirl_radius : hint_range(0.05, 1.5) = 0.65;
// Slow angular movement after the swirl has appeared.
uniform float swirl_speed : hint_range(0.0, 1.0) = 0.08;
// Amount of irregular UV displacement applied to the mist.
uniform float distortion_strength : hint_range(0.0, 0.15) = 0.008;

// IMPOSSIBLE SHADOWS
// Maximum darkness of the emerging masses.
uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.0;
// Approximate rate at which a new shadow event begins.
uniform float shadow_frequency : hint_range(0.01, 1.0) = 0.08;
// Scale of the shadow masses. Lower values make broader shapes.
uniform float shadow_size : hint_range(0.4, 6.0) = 1.4;

// PALETTE
// Base colour of the void behind every layer.
uniform vec4 void_color : source_color = vec4(0.012, 0.014, 0.022, 1.0);
// Main colour carried by the fog.
uniform vec4 fog_color : source_color = vec4(0.12, 0.15, 0.20, 1.0);


float hash21(vec2 point) {
	// The previous polynomial hash showed directional correlation at broad
	// scales. This small sine hash avoids visible vertical cell bands.
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453123);
}


float value_noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 local = fract(point);
	vec2 blend = local * local * (3.0 - 2.0 * local);

	float a = hash21(cell);
	float b = hash21(cell + vec2(1.0, 0.0));
	float c = hash21(cell + vec2(0.0, 1.0));
	float d = hash21(cell + vec2(1.0, 1.0));

	return mix(mix(a, b, blend.x), mix(c, d, blend.x), blend.y);
}


float fog_noise(vec2 point) {
	// Rotate and offset every octave so their grid boundaries do not align.
	float noise_value = value_noise(point) * 0.57;
	point = mat2(vec2(0.80, -0.60), vec2(0.60, 0.80)) * point;
	noise_value += value_noise(point * 2.03 + vec2(13.7, -4.1)) * 0.29;
	point = mat2(vec2(0.60, 0.80), vec2(-0.80, 0.60)) * point;
	noise_value += value_noise(point * 4.11 + vec2(-8.2, 6.7)) * 0.14;
	return noise_value;
}


mat2 rotation(float angle) {
	float sine = sin(angle);
	float cosine = cos(angle);
	return mat2(vec2(cosine, -sine), vec2(sine, cosine));
}


void fragment() {
	float time = TIME;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect_ratio = screen_size.x / screen_size.y;
	vec2 centred = (UV - 0.5) * vec2(aspect_ratio, 1.0);

	float radial_distance = length(centred);
	float swirl_mask = 1.0 - smoothstep(swirl_radius * 0.2, swirl_radius, radial_distance);
	float swirl_angle = swirl_strength * swirl_mask * (0.45 + time * swirl_speed * 0.05);
	vec2 dream_space = rotation(swirl_angle) * centred;

	vec2 distortion_sample = dream_space * 2.1 + vec2(time * 0.012, -time * 0.009);
	vec2 distortion = vec2(
		value_noise(distortion_sample),
		value_noise(distortion_sample + 31.4)
	) - vec2(0.5);
	dream_space += distortion * distortion_strength;

	vec2 broad_drift = vec2(time * fog_speed * 0.13, -time * fog_speed * 0.08);
	vec2 detail_drift = vec2(-time * fog_speed * 0.09, time * fog_speed * 0.15);

	float broad_fog = fog_noise(
		dream_space * fog_scale + broad_drift + distortion * 0.24
	);
	vec2 rotated_detail_space = rotation(-0.68) * dream_space;
	float fine_fog = fog_noise(
		rotated_detail_space * fog_scale * 2.35 + detail_drift - distortion * 0.31
	);

	float fog_field = broad_fog * 0.72 + fine_fog * 0.28;
	float fog_shape = smoothstep(0.30, 0.76, fog_field);
	float breathing = 0.97 + sin(time * 0.18) * 0.03;

	// The centre is only slightly calmer. This protects the card without
	// producing a visible vignette or a bright halo.
	float centre_distance = length(centred * vec2(0.72, 1.05));
	float outer_presence = smoothstep(0.10, 0.78, centre_distance);
	float spatial_density = mix(0.72, 1.08, outer_presence);
	float fog_amount = clamp(
		fog_shape * fog_density * breathing * spatial_density,
		0.0,
		1.0
	);

	vec3 colour = mix(void_color.rgb, fog_color.rgb, fog_amount);

	// Uniform branches are coherent for the whole draw call and avoid paying
	// for disabled shadow masses in the quieter dream states.
	if (shadow_intensity > 0.0001) {
		float shadow_clock = time * max(shadow_frequency, 0.001);
		float shadow_event = floor(shadow_clock);
		float shadow_age = fract(shadow_clock);
		float event_seed = hash21(vec2(shadow_event, shadow_event * 0.37));
		vec2 shadow_offset = vec2(
			hash21(vec2(shadow_event, 4.3)),
			hash21(vec2(8.7, shadow_event))
		) - vec2(0.5);
		float shadow_field = fog_noise(
			(dream_space + shadow_offset * 0.55) * shadow_size + vec2(event_seed * 17.0)
		);
		float shadow_shape = smoothstep(0.58, 0.78, shadow_field);
		float quick_appearance = smoothstep(0.0, 0.08, shadow_age);
		float slow_dissolve = 1.0 - smoothstep(0.16, 1.0, shadow_age);
		float shadow_amount = shadow_shape * quick_appearance * slow_dissolve * shadow_intensity;
		colour *= 1.0 - shadow_amount * 0.42;
	}

	COLOR = vec4(colour, 1.0);
}
