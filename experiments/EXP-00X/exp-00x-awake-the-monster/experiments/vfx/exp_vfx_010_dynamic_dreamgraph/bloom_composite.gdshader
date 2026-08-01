shader_type canvas_item;

// Bloom de doble anillo (caliente + amplio) sobre un SubViewport HDR
// (use_hdr_2d = true), para que los "sparkles" sobre-brillantes de
// dynamic_graph_view.gd (RGB > 1) no se recorten antes de llegar aqui.

uniform float bloom_threshold : hint_range(0.0, 2.0) = 0.35;
uniform float bloom_intensity : hint_range(0.0, 6.0) = 2.2;
uniform float bloom_radius : hint_range(0.0, 0.02) = 0.006;
uniform int bloom_samples : hint_range(4, 24) = 12;

uniform float bloom_radius_wide : hint_range(0.0, 0.08) = 0.022;
uniform float bloom_intensity_wide : hint_range(0.0, 4.0) = 1.1;
uniform int bloom_samples_wide : hint_range(4, 24) = 10;

uniform float bloom_falloff : hint_range(1.0, 4.0) = 1.8;
uniform float exposure : hint_range(0.2, 3.0) = 1.1;

vec3 sample_ring(sampler2D tex, vec2 uv, float radius, int samples, float threshold) {
	vec3 accum = vec3(0.0);
	for (int i = 0; i < samples; i++) {
		float angle = (float(i) / float(samples)) * TAU;
		float radius_step = radius * (0.35 + 0.65 * fract(float(i) * 0.61803398875));
		vec2 offset = vec2(cos(angle), sin(angle)) * radius_step;
		vec3 sample_color = texture(tex, uv + offset).rgb;
		float brightness = max(sample_color.r, max(sample_color.g, sample_color.b));
		float contribution = smoothstep(threshold, threshold + 0.25, brightness);
		accum += sample_color * contribution;
	}
	return accum / float(samples);
}

void fragment() {
	vec4 base = texture(TEXTURE, UV);

	vec3 hot = sample_ring(TEXTURE, UV, bloom_radius, bloom_samples, bloom_threshold);
	vec3 wide = sample_ring(TEXTURE, UV, bloom_radius_wide, bloom_samples_wide, bloom_threshold * 0.6);

	vec3 bloom = pow(hot, vec3(1.0 / bloom_falloff)) * bloom_intensity;
	bloom += pow(wide, vec3(1.0 / bloom_falloff)) * bloom_intensity_wide;

	vec3 color = (base.rgb + bloom) * exposure;

	// Tonemap Reinhard: comprime el brillo hacia 1.0 en vez de recortarlo,
	// preservando la relacion entre canales (y por lo tanto el tono/color)
	// cuando R, G y B superan 1.0 al mismo tiempo.
	color = color / (color + vec3(1.0));

	COLOR = vec4(color, base.a);
}
