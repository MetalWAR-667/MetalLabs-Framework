shader_type canvas_item;

// vortex_vacio (08_cards.md, card_001_despertar): remolino de bruma monocromatica
// succionandose hacia un punto central. Sin ray marching, coste bajo (fbm de 3 octavas).

uniform float custom_time = 0.0;
uniform float rotation_speed : hint_range(0.0, 1.0) = 0.12;
uniform float suction_speed : hint_range(0.0, 1.0) = 0.08;
uniform float noise_scale : hint_range(1.0, 20.0) = 6.0;
uniform float flow_speed : hint_range(0.0, 1.0) = 0.15;
uniform float breath_speed : hint_range(0.0, 1.0) = 0.12;
uniform vec4 color_indigo : source_color = vec4(0.1019608, 0.0823529, 0.1568627, 1.0);
uniform vec4 color_oil_blue : source_color = vec4(0.0588235, 0.1098039, 0.1490196, 1.0);
uniform vec4 color_mist_peak : source_color = vec4(0.42, 0.36, 0.52, 1.0);

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 3; i++) {
		value += amplitude * value_noise(p);
		p *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 centered = (UV - vec2(0.5)) * vec2(1.7778, 1.0);
	float radius = length(centered);
	float angle = atan(centered.y, centered.x);

	float breath = sin(custom_time * breath_speed) * 0.5 + 0.5;

	float swirl_angle = angle + custom_time * rotation_speed + (1.0 / (radius + 0.15)) * 0.15;
	float swirl_radius = radius - mod(custom_time * suction_speed, 4.0);

	vec2 polar_uv = vec2(cos(swirl_angle), sin(swirl_angle)) * swirl_radius * noise_scale;
	vec2 flow_offset = vec2(custom_time * flow_speed, -custom_time * flow_speed * 0.7);
	float n = fbm(polar_uv + flow_offset);

	vec3 col = mix(color_oil_blue.rgb, color_indigo.rgb, smoothstep(0.0, 0.55, n));
	col = mix(col, color_mist_peak.rgb, smoothstep(0.55, 1.0, n));

	float intro_fade = smoothstep(0.0, 0.3, custom_time);
	float vignette = smoothstep(0.8, 0.1, radius);
	float alpha = vignette * mix(0.5, 0.9, breath) * intro_fade;

	COLOR = vec4(col, alpha);
}
