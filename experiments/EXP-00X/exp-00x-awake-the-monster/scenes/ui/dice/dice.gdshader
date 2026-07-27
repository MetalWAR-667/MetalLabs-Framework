shader_type canvas_item;

uniform sampler2D colormap : source_color;

void fragment() {
	vec4 source = texture(TEXTURE, UV);

	float grey = dot(
		source.rgb,
		vec3(0.299, 0.587, 0.114)
	);

	vec4 mapped = texture(colormap, vec2(grey, 0.5));

	COLOR = vec4(mapped.rgb, source.a);
}