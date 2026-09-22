extends DemonModel

class_name DemonSloth

func getLocID() -> String: return super.getLocID() + "SLOTH"

func getDirName() -> String:
	return "sloth"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityFogOfMind, 
		AbilityAtrophy, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior]

func getStartingRingTypes() -> Array[Script]:
	return [RingAmazoniteClusterRing, RingBlankBand]
