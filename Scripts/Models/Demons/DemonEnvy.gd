extends DemonModel

class_name DemonEnvy

func getLocID() -> String: return super.getLocID() + "ENVY"

func getDirName() -> String:
	return "envy"

func getStartingAbilityTypes() -> Array[Script]: 
	return [AbilityFormlessLikeWater, 
		AbilityPhaseChange, AbilityDragToSea, AbilityUnchartedWaters, AbilityCounterweightExterior, 
		AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior, AbilityCounterweightExterior]

func getStartingRingTypes() -> Array[Script]: 
	return [RingDualTungstenSignate]
