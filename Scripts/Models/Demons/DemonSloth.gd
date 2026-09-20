extends DemonModel

class_name DemonSloth

func getLocID() -> String: return super.getLocID() + "SLOTH"

func getDirName() -> String:
	return "sloth"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityConsumeTheStars, 
		AbilityStoppage]

func getStartingRingTypes() -> Array[Script]:
	return [RingAmazoniteClusterRing, RingBlankBand]
