extends DemonModel

class_name DemonGluttony

func getLocID() -> String: return super.getLocID() + "GLUTTONY"

func getDirName() -> String:
	return "gluttony"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityConsumeTheStars, \
		AbilityDevouringSickness]

func getStartingRingTypes() -> Array[Script]: 
	return [RingVanityRing, RingVanityRing, RingVanityRing]
