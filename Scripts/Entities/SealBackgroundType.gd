enum SealBackgroundType {
	YELLOW, #s=0, x=1, y=0
	YELLOW_DARK, #s=1, x=1, y=0
	ORANGE, #s=2, x=1, y=0
	ORANGE_DARK, #s=3, x=1, y=0
	RED, #s=4, x=1, y=0
	
	PINK, #s=7, x=1, y=0
	MAROON, #s=10, x=1, y=0
	MAROON_DARK, #s=11, x=1, y=0
	
	PINK_LIGHT, #s=14, x=1, y=0
	PURPLE, #s=17, x=1, y=0
	PURPLE_DARK, #s=18, x=1, y=0
	BLACK, #s=19, x=1, y=0
	
	RED_DARK, #s=6, x=0, y=1
	CHROMATIC, #s=0, x=0, y=1
	CHROMATIC_DARK, #s=1, x=0, y=1
}

static func entityToShaderData(sealBackground : int) -> Dictionary:
	var rtn : Dictionary = {"start":0, "offsetX":1, "offsetY":0}
	match sealBackground:
		SealBackgroundType.YELLOW:
			pass
		SealBackgroundType.YELLOW_DARK:
			rtn["start"] = 1
		SealBackgroundType.ORANGE:
			rtn["start"] = 2
		SealBackgroundType.ORANGE_DARK:
			rtn["start"] = 3
		SealBackgroundType.RED:
			rtn["start"] = 4
		
		SealBackgroundType.PINK:
			rtn["start"] = 7
		SealBackgroundType.MAROON:
			rtn["start"] = 10
		SealBackgroundType.MAROON_DARK:
			rtn["start"] = 11
		
		SealBackgroundType.PINK_LIGHT:
			rtn["start"] = 14
		SealBackgroundType.PURPLE:
			rtn["start"] = 17
		SealBackgroundType.PURPLE_DARK:
			rtn["start"] = 18
		SealBackgroundType.BLACK:
			rtn["start"] = 19
		
		SealBackgroundType.RED_DARK:
			rtn["start"] = 6
			rtn["offsetX"] = 0
			rtn["offsetY"] = 1
		SealBackgroundType.CHROMATIC:
			rtn["start"] = 0
			rtn["offsetX"] = 0
			rtn["offsetY"] = 1
		SealBackgroundType.CHROMATIC_DARK:
			rtn["start"] = 1
			rtn["offsetX"] = 0
			rtn["offsetY"] = 1
	return rtn
