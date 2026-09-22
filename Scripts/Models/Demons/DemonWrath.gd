extends DemonModel

class_name DemonWrath

func getLocID() -> String: return super.getLocID() + "WRATH"

func getDirName() -> String:
	return "wrath"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityPlungeIntoDarkness, 
		AbilityOceansDescent, AbilityWait, AbilityWait, AbilityWait, 
		AbilityWait, AbilityWait, AbilityWait, AbilityWait]

func getStartingRingTypes() -> Array[Script]: 
	return []
