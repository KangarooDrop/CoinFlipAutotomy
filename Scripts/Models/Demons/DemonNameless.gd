extends DemonModel

class_name DemonNameless

func getLocID() -> String: return super.getLocID() + "NAMELESS"

func getDirName() -> String:
	return "nameless"

func getStartingAbilityTypes() -> Array[Script]: 
	return [
		]

func getStartingRingTypes() -> Array[Script]: 
	return []
