shader_type canvas_item;

// EXP-VFX-012 — Analytical DreamGraph.
// One fullscreen pass: SDF segments, stabilized inverse-square glow,
// asynchronous breathing and an optional spherical "cosmic lens".

uniform float aspect = 1.7777778;
uniform float graph_time = 0.0;

uniform int node_count = 0;
// xy: normalized position, z: intensity * reveal, w: stable phase.
uniform vec4 node_data[32];
uniform int connection_count = 0;
// xy: node indices, z: reveal, w: stable phase.
uniform vec4 connection_data[64];

uniform float node_size : hint_range(0.001, 0.025) = 0.006;
uniform float node_glow : hint_range(0.0, 0.01) = 0.0018;
uniform float line_width : hint_range(0.0002, 0.012) = 0.0022;
uniform float line_glow : hint_range(0.0, 0.004) = 0.00034;
uniform float breath_amount : hint_range(0.0, 0.8) = 0.24;
uniform float breath_speed : hint_range(0.02, 1.0) = 0.16;
uniform float exposure : hint_range(0.1, 3.0) = 1.15;

// The five levers of responsible cosmic-marble operation.
uniform bool enable_cosmic_lens = true;
uniform float lens_radius : hint_range(0.15, 0.7) = 0.46;
uniform float lens_strength : hint_range(0.0, 1.0) = 0.72;
uniform float lens_edge : hint_range(0.0, 1.0) = 0.42;
uniform float lens_refraction : hint_range(-0.8, 0.8) = 0.28;

vec2 to_space(vec2 uv) {
	return (uv - 0.5) * vec2(aspect, 1.0);
}

float sd_segment(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / max(dot(ba, ba), 0.000001), 0.0, 1.0);
	return length(pa - ba * h);
}

float breathing(float phase, float frequency_scale) {
	return 1.0 + sin(graph_time * breath_speed * frequency_scale + phase * TAU) * breath_amount;
}

vec3 phase_color(float phase) {
	vec3 cold = vec3(0.12, 0.48, 1.0);
	vec3 dream = vec3(0.72, 0.18, 1.0);
	return mix(cold, dream, 0.5 + 0.5 * sin(phase * TAU + graph_time * 0.025));
}

void fragment() {
	vec2 original_p = to_space(UV);
	vec2 p = original_p;
	float radius = max(lens_radius, 0.001);
	float radial = length(original_p) / radius;
	float sphere_mask = 1.0;
	float rim = 0.0;

	if (enable_cosmic_lens) {
		// A spherical coordinate warp is applied before all distance evaluation.
		// The center remains calm; refraction grows toward the glass boundary.
		float inside = 1.0 - smoothstep(0.985, 1.0, radial);
		float curvature = 1.0 - sqrt(max(1.0 - min(radial * radial, 0.999), 0.001));
		float warp = 1.0 + lens_refraction * curvature * lens_strength;
		p /= max(warp, 0.15);
		sphere_mask = mix(1.0, inside, lens_strength);
		rim = exp(-pow((radial - 0.965) / 0.035, 2.0)) * lens_edge;
	}

	vec3 light = vec3(0.0);

	for (int i = 0; i < node_count; i++) {
		vec4 node = node_data[i];
		vec2 node_position = to_space(node.xy);
		float pulse = breathing(node.w, 0.83 + fract(node.w * 7.13) * 0.34);
		float distance_to_node = length(p - node_position);
		float core = smoothstep(node_size * pulse, node_size * 0.2, distance_to_node);
		float inverse_square = node_glow / (0.000025 + distance_to_node * distance_to_node);
		light += phase_color(node.w) * (core * 1.8 + inverse_square) * node.z * pulse;
	}

	for (int i = 0; i < connection_count; i++) {
		vec4 connection = connection_data[i];
		int index_a = int(connection.x);
		int index_b = int(connection.y);
		vec4 node_a = node_data[index_a];
		vec4 node_b = node_data[index_b];
		float pulse = breathing(connection.w, 0.71 + fract(connection.w * 5.91) * 0.46);
		float distance_to_line = sd_segment(p, to_space(node_a.xy), to_space(node_b.xy));
		float core = smoothstep(line_width * pulse, line_width * 0.35, distance_to_line);
		float inverse_square = line_glow / (0.000018 + distance_to_line * distance_to_line);
		vec3 line_color = phase_color(mix(node_a.w, node_b.w, 0.5));
		light += line_color * (core * 0.75 + inverse_square) * connection.z * pulse;
	}

	light *= exposure * sphere_mask;
	light += vec3(0.20, 0.38, 0.62) * rim;

	// Filmic compression keeps overlap white-hot without infinities or clipping.
	vec3 color = 1.0 - exp(-light);
	float void_gradient = max(0.0, 1.0 - length(original_p) * 0.75);
	color += vec3(0.004, 0.006, 0.014) * void_gradient;
	COLOR = vec4(color, 1.0);
}
