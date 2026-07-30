shader_type canvas_item;

uniform float t : hint_range(0.0, 1.0, 0.001) = 0.0;
varying vec2 pixel_pos;

const int SPIN_NUM = 4;
const float SIDE_RATIO = 0.1;

const float ROOT_TWO = sqrt(2.0);

void vertex() {
	pixel_pos = VERTEX;
}

void fragment() 
{
	COLOR.a = 0.0;
	vec2 control_size = pixel_pos / UV;
	vec2 centeredUV = (UV - 0.5) * 2.0;
	float aspect = control_size.x/control_size.y;
	if(aspect >= 1.0)
		centeredUV.y /= aspect;
	else
		centeredUV.x *= aspect;
	
	float modifiedT = t*ROOT_TWO;
	float sideSpinOffset = abs(cos(t*PI*float(SPIN_NUM)));
	vec2 spinTransformedLeftUV = vec2((centeredUV.x+SIDE_RATIO*(1.0-sideSpinOffset)*modifiedT)/sideSpinOffset, centeredUV.y);
	vec2 spinTransformedRightUV = vec2((centeredUV.x-SIDE_RATIO*(1.0-sideSpinOffset)*modifiedT)/sideSpinOffset, centeredUV.y);
	
	if(length(spinTransformedRightUV) < modifiedT)
		COLOR.a = 1.0;
	else if(abs(centeredUV.y)<modifiedT && abs(centeredUV.x)<modifiedT*SIDE_RATIO)
		COLOR.a = 1.0;
	else if(length(spinTransformedLeftUV) < modifiedT)
		COLOR.a = 1.0;
}