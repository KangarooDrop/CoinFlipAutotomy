extends DemonModel

class_name DemonGluttony

func getLocID() -> String: return super.getLocID() + "GLUTTONY"

func getDirName() -> String:
	return "gluttony"

func getStartingCoinPieceTypes() -> Array[Script]: 
	return [CPAbyssalMaw, CPDevouringSickness, CPCounterweightExterior, CPCounterweightExterior]

func getStartingRingTypes() -> Array[Script]: 
	return [RingVanityRing, RingVanityRing, RingVanityRing]
