extends DemonModel

class_name DemonGluttony

func getLocID() -> String: return super.getLocID() + "GLUTTONY"

func getDirName() -> String:
	return "gluttony"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityConsumeTheStars, 
		AbilityDevour, AbilityPlayWithYourFood, AbilityWait, AbilityHorrorVacui,
		AbilityWait, AbilityWait, AbilityWait, AbilityWait]

func getStartingRingTypes() -> Array[Script]: 
	return [RingVanityRing, RingVanityRing, RingVanityRing]
