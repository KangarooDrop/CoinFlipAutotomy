extends DemonModel

class_name DemonEnvy

func getLocID() -> String: return super.getLocID() + "ENVY"

func getDirName() -> String:
	return "envy"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityFormlessLikeWater, 
		AbilityOceansDescent, AbilityWait, AbilityWait, AbilityWait, 
		AbilityWait, AbilityWait, AbilityWait, AbilityWait]

func getStartingRingTypes() -> Array[Script]: 
	return [RingDualTungstenSignate]
