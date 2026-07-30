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

float fog_mask(sampler2D source, vec2 uv, float layer_contrast) {
	float sample_value = texture(source, uv).r;
	float shaped = clamp((sample_value - 0.45) * layer_contrast + 0.5, 0.0, 1.0);
	return smoothstep(0.0, 1.0, shaped);
}

vec3 blend_fog(vec3 base, vec3 tint, float mask, float layer_opacity) {
	return mix(base, tint, mask * layer_opacity);
}

void fragment() {
	vec2 aspect_uv = (UV - vec2(0.5)) * vec2(16.0 / 9.0, 1.0);
	vec3 color = void_color.rgb;

	if (background_enabled) {
		vec2 uv = aspect_uv * background_scale;
		uv += background_direction * background_speed * TIME;
		color = blend_fog(color, background_tint.rgb,
			fog_mask(background_source, uv, background_contrast), background_opacity);
	}
	if (mid_enabled) {
		vec2 uv = aspect_uv * mid_scale;
		uv += mid_direction * mid_speed * TIME;
		color = blend_fog(color, mid_tint.rgb,
			fog_mask(mid_source, uv, mid_contrast), mid_opacity);
	}
	if (foreground_enabled) {
		vec2 uv = aspect_uv * foreground_scale;
		uv += foreground_direction * foreground_speed * TIME;
		color = blend_fog(color, foreground_tint.rgb,
			fog_mask(foreground_source, uv, foreground_contrast), foreground_opacity);
	}

	COLOR = vec4(color, 1.0);
}
