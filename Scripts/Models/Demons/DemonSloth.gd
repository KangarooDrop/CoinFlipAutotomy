extends DemonModel

class_name DemonSloth

func getLocID() -> String: return super.getLocID() + "SLOTH"

func getDirName() -> String:
	return "sloth"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityFogOfMind, 
		AbilitySealAway, AbilitySaltTheEarth, AbilityCounterweightExterior, AbilityCounterweightExterior, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior]

func getStartingRingTypes() -> Array[Script]:
	return [RingAzuriteFacetRing, RingBandOfAThousandCuts]
