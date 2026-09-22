extends DemonModel

class_name DemonLust

func getLocID() -> String: return super.getLocID() + "LUST"

func getDirName() -> String:
	return "lust"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityBurningObsession, 
		AbilityOceansDescent, AbilityWait, AbilityWait, AbilityWait, 
		AbilityWait, AbilityWait, AbilityWait, AbilityWait]
