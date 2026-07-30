extends DemonModel

class_name DemonEnvy

func getLocID() -> String: return super.getLocID() + "ENVY"

func getDirName() -> String:
	return "envy"

func getStartingCoinPieceTypes() -> Array[Script]: 
	return [CPCounterweightCore, 
		CPOceansDescent, CPDismay, CPCounterweightExterior]

func getStartingFingerRingTypes() -> Array[Script]: 
	return [RingBucketBrimCrustacean, RingPreownedLoop, RingCircleOfLeeches]
