shader_type canvas_item;

uniform float network_time = 0.0;
uniform float node_speed = 1.0;
uniform float node_amplitude = 0.4;
uniform float depth_speed = 0.05;
uniform float line_width = 0.014;
uniform float connection_distance = 0.8;
uniform float connection_intensity = 1.0;
uniform float node_intensity = 1.0;
uniform float flicker_speed = 2.0;
uniform float overall_scale = 1.5;
uniform float background_intensity = 0.01;
uniform float global_intensity = 1.0;
uniform vec4 main_color : source_color = vec4(1.0);
uniform float color_variation = 1.0;
uniform float color_cycle_speed = 2.0;
uniform bool show_nodes = true;
uniform bool show_connections = true;
uniform bool single_layer = false;

float distLine(vec2 p, vec2 a, vec2 b) {
	vec2 ap = p - a;
	vec2 ab = b - a;
	float denominator = max(dot(ab, ab), 0.000001);
	float aDotB = clamp(dot(ap, ab) / denominator, 0.0, 1.0);
	return length(ap - ab * aDotB);
}

float drawLine(vec2 uv, vec2 a, vec2 b) {
	float line = smoothstep(line_width, line_width * 0.7142857, distLine(uv, a, b));
	float dist = length(b-a);
	float distance_gate = smoothstep(connection_distance * 1.625, connection_distance, dist);
	float accent = smoothstep(0.04, 0.03, abs(dist - connection_distance * 0.9375));
	return line * (distance_gate * 0.5 + accent) * connection_intensity;
}

float n21(vec2 i) {
	i += fract(i * vec2(223.64, 823.12));
	i += dot(i, i + 23.14);
	return fract(i.x * i.y);
}

vec2 n22(vec2 i) {
	float x = n21(i);
	return vec2(x, n21(i+x));
}

vec2 getPoint(vec2 id, vec2 offset) {
	return offset + sin(n22(id + offset) * network_time * node_speed) * node_amplitude;
}

float layer(vec2 uv) {
	float m = 0.0;
	float t = network_time * flicker_speed;
	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv) - 0.5;
	vec2 p[9];
	int index = 0;

	for (float y = -1.0; y <= 1.0; y++) {
		for (float x = -1.0; x <= 1.0; x++) {
			p[index++] = getPoint(id, vec2(x, y));
		}
	}

	for (int point_index = 0; point_index < 9; point_index++) {
		if (show_connections) {
			m += drawLine(gv, p[4], p[point_index]);
		}
		if (show_nodes) {
			float node_distance = max(length(gv - p[point_index]), 0.002);
			float sparkle = 1.0 / pow(node_distance, 1.5) * 0.005;
			m += sparkle * node_intensity * (
				sin(t + fract(p[point_index].x) * 12.23) * 0.4 + 0.6
			);
		}
	}

	if (show_connections) {
		m += drawLine(gv, p[1], p[3]);
		m += drawLine(gv, p[1], p[5]);
		m += drawLine(gv, p[7], p[3]);
		m += drawLine(gv, p[7], p[5]);
	}
	return m;
}

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = (FRAGCOORD.xy - 0.5 * resolution.xy) / resolution.y;
	vec3 original_cycle = (
		sin(network_time * color_cycle_speed * vec3(0.234, 0.324, 0.768))
		* 0.4 + 0.6
	);
	vec3 color_cycle = main_color.rgb * mix(vec3(1.0), original_cycle, color_variation);
	vec3 color = vec3(0.0);
	color_cycle.x += (uv.x + 0.5) * color_variation;
	color += pow(max(-uv.y + 0.5, 0.0), 5.0) * background_intensity * color_cycle;

	float network = 0.0;
	for (float layer_index = 0.0; layer_index <= 1.0; layer_index += 1.0 / 4.0) {
		if (!single_layer || abs(layer_index - 0.5) < 0.01) {
			float depth = fract(layer_index + network_time * depth_speed);
			float size = mix(15.0, 0.1, depth) * overall_scale;
			float fade = smoothstep(0.0, 1.0, depth) * smoothstep(1.0, 0.9, depth);
			network += layer(size * uv + layer_index * 10.0) * fade;
		}
	}

	color += network * color_cycle;
	COLOR = vec4(color * global_intensity, 1.0);
}
