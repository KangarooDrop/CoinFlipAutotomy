shader_type canvas_item;

uniform sampler2D textureFrom : filter_nearest;
uniform sampler2D textureTo : filter_nearest;
uniform float t : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() 
{
	vec4 c0 = textureLod(textureFrom, UV, 0.0);
	vec4 c1 = textureLod(textureTo, UV, 0.0);
	vec4 color = mix(c0, c1, t);
	COLOR = color;
}
