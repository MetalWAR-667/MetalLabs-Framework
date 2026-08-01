shader_type canvas_item;

// Mismo modelo de datos dinamico que EXP-VFX-010 (un nodo por carta,
// conexiones explicitas), pero el glow ya no es geometria (draw_circle +
// bloom de post-proceso): es matematica analitica per-pixel, al estilo del
// "sparkle" (1/dist^1.5) y las lineas SDF de EXP-VFX-009. Sin SubViewport,
// sin pasada de bloom: el brillo nace directo del fragment shader.

uniform float aspect = 1.7778;
uniform float time = 0.0;

uniform int node_count = 0;
// xy = posicion normalizada (0-1), z = intensidad * reveal, w = fase de color/drift (0-1)
uniform vec4 node_data[64];

uniform int connection_count = 0;
// x = indice nodo A, y = indice nodo B, z = reveal, w = sin uso
uniform vec4 connection_data[128];

uniform float sparkle_radius : hint_range(0.0001, 0.02) = 0.0028;
uniform float sparkle_intensity : hint_range(0.0, 0.1) = 0.024;
uniform float line_width : hint_range(0.0002, 0.01) = 0.0016;
uniform float line_intensity : hint_range(0.0, 3.0) = 0.9;

uniform float saturation : hint_range(0.0, 1.0) = 0.85;
uniform float color_cycle_speed : hint_range(0.0, 2.0) = 0.2;

uniform float drift_amount : hint_range(0.0, 0.06) = 0.02;
uniform float drift_speed : hint_range(0.0, 1.0) = 0.12;
uniform float zoom_amount : hint_range(0.0, 0.6) = 0.18;
uniform float zoom_speed : hint_range(0.0, 1.0) = 0.09;

uniform float exposure : hint_range(0.2, 3.0) = 1.0;

vec3 hue_to_rgb(float hue, float sat) {
	vec3 rgb = clamp(abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	return mix(vec3(1.0), rgb, sat);
}

vec2 to_screen(vec2 normalized_position) {
	return (normalized_position - 0.5) * vec2(aspect, 1.0);
}

vec2 node_drift(int index, float phase) {
	float p = float(index) * 1.731 + phase * TAU;
	return vec2(
		sin(time * drift_speed + p),
		cos(time * drift_speed * 0.83 + p * 1.19)
	) * drift_amount;
}

void fragment() {
	vec2 p = to_screen(UV);
	float zoom = 1.0 + sin(time * zoom_speed) * zoom_amount;
	p /= zoom;

	vec3 color = vec3(0.0);

	for (int i = 0; i < node_count; i++) {
		vec4 n = node_data[i];
		vec2 node_pos = to_screen(n.xy) + node_drift(i, n.w);
		float dist = max(length(p - node_pos), 0.0012);
		float sparkle = sparkle_radius / pow(dist, 1.5) * sparkle_intensity;
		vec3 node_color = hue_to_rgb(fract(n.w + time * color_cycle_speed), saturation);
		color += node_color * sparkle * n.z;
	}

	for (int i = 0; i < connection_count; i++) {
		vec4 c = connection_data[i];
		int index_a = int(c.x);
		int index_b = int(c.y);
		vec4 na = node_data[index_a];
		vec4 nb = node_data[index_b];
		vec2 pos_a = to_screen(na.xy) + node_drift(index_a, na.w);
		vec2 pos_b = to_screen(nb.xy) + node_drift(index_b, nb.w);

		vec2 ab = pos_b - pos_a;
		vec2 ap = p - pos_a;
		float t = clamp(dot(ap, ab) / max(dot(ab, ab), 0.000001), 0.0, 1.0);
		float line_dist = length(ap - ab * t);
		float line = smoothstep(line_width, line_width * 0.35, line_dist);

		float mix_hue = fract((na.w + nb.w) * 0.5 + time * color_cycle_speed);
		vec3 line_color = hue_to_rgb(mix_hue, saturation);
		color += line_color * line * line_intensity * c.z;
	}

	color *= exposure;
	color = color / (color + vec3(1.0));

	COLOR = vec4(color, 1.0);
}
