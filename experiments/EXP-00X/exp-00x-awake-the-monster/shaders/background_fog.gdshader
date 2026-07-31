shader_type canvas_item;
render_mode unshaded;

uniform sampler2D background_source : repeat_enable, filter_linear;
uniform sampler2D mid_source : repeat_enable, filter_linear;
uniform sampler2D foreground_source : repeat_enable, filter_linear;

uniform float background_scale = 0.45;
uniform float background_speed = 0.0015;
uniform vec2 background_direction = vec2(0.7, 0.2);
uniform float background_opacity = 0.40;
uniform float background_contrast = 0.75;
uniform vec4 background_tint : source_color = vec4(0.18, 0.25, 0.32, 1.0);

uniform float mid_scale = 1.2;
uniform float mid_speed = 0.006;
uniform vec2 mid_direction = vec2(-0.35, 0.8);
uniform float mid_opacity = 0.45;
uniform float mid_contrast = 1.25;
uniform vec4 mid_tint : source_color = vec4(0.25, 0.33, 0.40, 1.0);

uniform float foreground_scale = 2.4;
uniform float foreground_speed = 0.012;
uniform vec2 foreground_direction = vec2(0.85, -0.25);
uniform float foreground_opacity = 0.18;
uniform float foreground_contrast = 1.60;
uniform vec4 foreground_tint : source_color = vec4(0.34, 0.40, 0.45, 1.0);
uniform vec4 void_color : source_color = vec4(0.012, 0.022, 0.04, 1.0);

uniform vec2 field_center = vec2(0.5, 0.5);
uniform float field_radius = 0.62;
uniform float field_strength = 0.18;
uniform float field_falloff = 0.42;
uniform float temporal_drift = 0.18;
uniform float background_field_influence = 0.22;
uniform float mid_field_influence = 0.82;
uniform float foreground_field_influence = 0.38;

uniform float success_flash : hint_range(0.0, 1.0) = 0.0;
uniform float failure_pulse : hint_range(0.0, 1.0) = 0.0;
uniform float feedback_distortion : hint_range(0.0, 1.0) = 0.0;


float fog_mask(sampler2D source, vec2 uv, float layer_contrast) {
	float sample_value = texture(source, uv).r;
	float shaped = clamp(
		(sample_value - 0.45) * layer_contrast + 0.5,
		0.0,
		1.0
	);
	return smoothstep(0.0, 1.0, shaped);
}


vec3 blend_fog(
	vec3 base,
	vec3 tint,
	float mask,
	float layer_opacity
) {
	return mix(base, tint, mask * layer_opacity);
}


vec2 field_offset(vec2 position, float aspect_ratio) {
	float slow_time = TIME * 0.017;
	vec2 center = (
		(field_center - vec2(0.5))
		* vec2(aspect_ratio, 1.0)
	);
	center += vec2(
		sin(slow_time * 0.73),
		cos(slow_time * 0.57)
	) * temporal_drift * 0.08;

	vec2 local = position - center;
	float distance_to_center = max(length(local), 0.0001);
	vec2 radial = local / distance_to_center;
	vec2 tangent = vec2(-radial.y, radial.x);
	float area = 1.0 - smoothstep(
		0.0,
		field_radius + max(field_falloff, 0.01),
		distance_to_center
	);
	return tangent * field_strength * area * 0.22;
}


void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect_ratio = screen_size.x / screen_size.y;
	vec2 aspect_uv = (
		(UV - vec2(0.5))
		* vec2(aspect_ratio, 1.0)
	);
	vec2 deformation = field_offset(aspect_uv, aspect_ratio);
	deformation *= 1.0 + feedback_distortion * 0.65;
	deformation += vec2(
		sin(TIME * 37.0 + aspect_uv.y * 4.0),
		cos(TIME * 31.0 + aspect_uv.x * 3.0)
	) * feedback_distortion * 0.006;
	vec3 color = void_color.rgb;

	vec2 background_uv = (
		aspect_uv
		+ deformation * background_field_influence
	) * background_scale;
	background_uv += (
		background_direction * background_speed * TIME
	);
	color = blend_fog(
		color,
		background_tint.rgb,
		fog_mask(
			background_source,
			background_uv,
			background_contrast
		),
		background_opacity
	);

	vec2 mid_uv = (
		aspect_uv
		+ deformation * mid_field_influence
	) * mid_scale;
	mid_uv += mid_direction * mid_speed * TIME;
	color = blend_fog(
		color,
		mid_tint.rgb,
		fog_mask(mid_source, mid_uv, mid_contrast),
		mid_opacity
	);

	vec2 foreground_uv = (
		aspect_uv
		+ deformation * foreground_field_influence
	) * foreground_scale;
	foreground_uv += (
		foreground_direction * foreground_speed * TIME
	);
	color = blend_fog(
		color,
		foreground_tint.rgb,
		fog_mask(
			foreground_source,
			foreground_uv,
			foreground_contrast
		),
		foreground_opacity
	);

	float cold_shape = 0.35 + fog_mask(
		mid_source,
		mid_uv + vec2(0.17, -0.11),
		1.6
	) * 0.65;
	vec3 cold_light = vec3(0.58, 0.68, 0.86);
	color = mix(
		color,
		cold_light,
		success_flash * cold_shape * 0.72
	);
	color *= 1.0 + success_flash * 0.42;

	float distance_from_center = length(aspect_uv);
	float oppressive_wave = (
		0.68
		+ sin(distance_from_center * 9.0 - TIME * 1.8) * 0.12
	);
	vec3 failure_color = vec3(0.22, 0.025, 0.035);
	color = mix(
		color,
		failure_color,
		failure_pulse * oppressive_wave * 0.58
	);
	color *= 1.0 - failure_pulse * 0.18;
	color = (
		(color - vec3(0.08))
		* (1.0 + failure_pulse * 0.22)
		+ vec3(0.08)
	);

	COLOR = vec4(color, 1.0);
}
