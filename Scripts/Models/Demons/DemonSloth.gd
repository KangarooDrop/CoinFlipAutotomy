extends DemonModel

class_name DemonSloth

func getLocID() -> String: return super.getLocID() + "SLOTH"

func getDirName() -> String:
	return "sloth"

func getStartingCoinPieceTypes() -> Array[Script]: 
	return [CPCounterweightCore, CPAtrophy]

func getStartingFingerRingTypes() -> Array[Script]:
	return [RingBowOfBellsEnd]
