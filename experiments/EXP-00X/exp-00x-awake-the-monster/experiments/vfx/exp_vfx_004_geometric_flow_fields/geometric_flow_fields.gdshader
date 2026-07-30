shader_type canvas_item;
render_mode unshaded;

uniform sampler2D background_source : repeat_enable, filter_linear;
uniform sampler2D mid_source : repeat_enable, filter_linear;
uniform sampler2D foreground_source : repeat_enable, filter_linear;

uniform bool background_enabled = true;
uniform float background_scale = 0.45;
uniform float background_speed = 0.0015;
uniform vec2 background_direction = vec2(0.7, 0.2);
uniform float background_opacity = 0.40;
uniform float background_contrast = 0.75;
uniform vec4 background_tint : source_color = vec4(0.18, 0.25, 0.32, 1.0);

uniform bool mid_enabled = true;
uniform float mid_scale = 1.2;
uniform float mid_speed = 0.006;
uniform vec2 mid_direction = vec2(-0.35, 0.8);
uniform float mid_opacity = 0.45;
uniform float mid_contrast = 1.25;
uniform vec4 mid_tint : source_color = vec4(0.25, 0.33, 0.40, 1.0);

uniform bool foreground_enabled = true;
uniform float foreground_scale = 2.4;
uniform float foreground_speed = 0.012;
uniform vec2 foreground_direction = vec2(0.85, -0.25);
uniform float foreground_opacity = 0.18;
uniform float foreground_contrast = 1.60;
uniform vec4 foreground_tint : source_color = vec4(0.34, 0.40, 0.45, 1.0);
uniform vec4 void_color : source_color = vec4(0.012, 0.022, 0.04, 1.0);

uniform bool field_enabled = true;
uniform int field_type : hint_enum("Vortex,Ring,Arc") = 0;
uniform vec2 field_center = vec2(0.43, 0.54);
uniform float field_radius = 0.62;
uniform float field_strength = 0.18;
uniform float field_falloff = 0.42;
uniform float field_rotation = -0.35;
uniform float temporal_drift = 0.18;
uniform float background_field_influence = 0.22;
uniform float mid_field_influence = 0.82;
uniform float foreground_field_influence = 0.38;
uniform bool field_debug = false;

float fog_mask(sampler2D source, vec2 uv, float layer_contrast) {
	float sample_value = texture(source, uv).r;
	float shaped = clamp((sample_value - 0.45) * layer_contrast + 0.5, 0.0, 1.0);
	return smoothstep(0.0, 1.0, shaped);
}

vec3 blend_fog(vec3 base, vec3 tint, float mask, float layer_opacity) {
	return mix(base, tint, mask * layer_opacity);
}

vec2 field_offset(vec2 position) {
	if (!field_enabled) {
		return vec2(0.0);
	}

	float slow_time = TIME * 0.017;
	vec2 center = (field_center - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	center += vec2(sin(slow_time * 0.73), cos(slow_time * 0.57))
		* temporal_drift * 0.08;
	vec2 local = position - center;
	float distance_to_center = max(length(local), 0.0001);
	vec2 radial = local / distance_to_center;
	vec2 tangent = vec2(-radial.y, radial.x);
	float safe_falloff = max(field_falloff, 0.01);

	if (field_type == 0) {
		float area = 1.0 - smoothstep(0.0, field_radius + safe_falloff, distance_to_center);
		return tangent * field_strength * area * 0.22;
	}

	float ring_distance = abs(distance_to_center - field_radius);
	float band = 1.0 - smoothstep(0.0, safe_falloff, ring_distance);
	if (field_type == 1) {
		return radial * field_strength * band * 0.18;
	}

	vec2 orientation = vec2(cos(field_rotation), sin(field_rotation));
	float angular_region = smoothstep(-0.35, 0.35, dot(radial, orientation));
	float arc = band * angular_region;
	return (tangent * 0.7 + radial * 0.3) * field_strength * arc * 0.20;
}

vec2 deform(vec2 position, float influence) {
	return position + field_offset(position) * influence;
}

void fragment() {
	vec2 aspect_uv = (UV - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	vec2 debug_offset = field_offset(aspect_uv);
	if (field_debug) {
		float magnitude = clamp(length(debug_offset) * 14.0, 0.0, 1.0);
		COLOR = vec4(vec3(0.08 + magnitude * 0.82), 1.0);
	} else {
		vec3 color = void_color.rgb;
		if (background_enabled) {
			vec2 uv = deform(aspect_uv, background_field_influence) * background_scale;
			uv += background_direction * background_speed * TIME;
			color = blend_fog(color, background_tint.rgb,
				fog_mask(background_source, uv, background_contrast), background_opacity);
		}
		if (mid_enabled) {
			vec2 uv = deform(aspect_uv, mid_field_influence) * mid_scale;
			uv += mid_direction * mid_speed * TIME;
			color = blend_fog(color, mid_tint.rgb,
				fog_mask(mid_source, uv, mid_contrast), mid_opacity);
		}
		if (foreground_enabled) {
			vec2 uv = deform(aspect_uv, foreground_field_influence) * foreground_scale;
			uv += foreground_direction * foreground_speed * TIME;
			color = blend_fog(color, foreground_tint.rgb,
				fog_mask(foreground_source, uv, foreground_contrast), foreground_opacity);
		}
		COLOR = vec4(color, 1.0);
	}
}
