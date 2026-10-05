extends DemonModel

class_name DemonPride

func getLocID() -> String: return super.getLocID() + "PRIDE"

func getDirName() -> String:
	return "pride"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityRandomCore, 
		AbilityRandomExterior, AbilityRandomExterior, AbilityRandomExterior, AbilityCounterweightExterior, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior]
