extends DemonModel

class_name DemonEnvy

func getLocID() -> String: return super.getLocID() + "ENVY"

func getDirName() -> String:
	return "envy"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityClingToLife, 
		AbilityOceansDescent, AbilityHesitance, AbilitySirensCall]

func getStartingRingTypes() -> Array[Script]: 
	return [RingDualTungstenSignate]
