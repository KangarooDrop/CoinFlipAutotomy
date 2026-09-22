extends DemonModel

class_name DemonGreed

func getLocID() -> String: return super.getLocID() + "GREED"

func getDirName() -> String:
	return "greed"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityCounterweightCore, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior]

func getStartingRingTypes() -> Array[Script]: 
	return []
