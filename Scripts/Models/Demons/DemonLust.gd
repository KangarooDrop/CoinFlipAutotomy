extends DemonModel

class_name DemonLust

func getLocID() -> String: return super.getLocID() + "LUST"

func getDirName() -> String:
	return "lust"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityBurningObsession, 
		AbilityOceansDescent, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior]

func getStartingRingTypes() -> Array[Script]: 
	return []
