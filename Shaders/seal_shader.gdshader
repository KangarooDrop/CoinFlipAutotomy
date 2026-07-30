shader_type canvas_item;
#include "shader_coloring.gdshaderinc"

uniform int start = 0;
uniform int offsetX = 1;
uniform int offsetY = 0;

void fragment() {
	vec4 color = textureLod(TEXTURE, UV, 0);
	float alpha = color.a;
	if(color.r == 1.0)
		color = colorMap[start+(offsetX+offsetY*7)*0];
	else if(color.r != 0.0)
		color = colorMap[start+(offsetX+offsetY*7)*1];
	else
		color = colorMap[start+(offsetX+offsetY*7)*2];
	color.a = alpha;
	COLOR = color;
}

