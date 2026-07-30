shader_type canvas_item;
#include "shader_coloring.gdshaderinc"

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

float getColorDist(vec4 c0, vec4 c1)
{
	return abs(c0.r - c1.r) + abs(c0.g - c1.g) + abs(c0.b - c1.b);
}

vec4 matchColor(vec4 color)
{
	int bestIndex = -1;
	float bestDist = 0.0;
	for(int i = 0; i < 21; ++i)
	{
		float currentDist = getColorDist(color, colorMap[i]);
		if(bestIndex == -1 || currentDist < bestDist)
		{
			bestIndex = i;
			bestDist = currentDist;
		}
	}
	return colorMap[bestIndex];
}

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0);
	vec4 posterized = matchColor(color);
	COLOR *= posterized;
}
