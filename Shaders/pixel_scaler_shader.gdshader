shader_type canvas_item;

uniform vec2 size = vec2(576.0, 324.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

float stepify(float val, float stepper)
{
	return float(int(val/stepper)) * stepper;
}

void fragment() {
	ivec2 texelPos = ivec2(int((SCREEN_UV.x * size.x)), int(SCREEN_UV.y * size.y));
	vec4 screenColor = texelFetch(SCREEN_TEXTURE, texelPos, 0);
	COLOR *= screenColor;
}
