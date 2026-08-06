extends DemonModel

class_name DemonEnvy

func getLocID() -> String: return super.getLocID() + "ENVY"

func getDirName() -> String:
	return "envy"

func getStartingCoinPieceTypes() -> Array[Script]: 
	return [CPDrownardsVictim, 
		CPOceansDescent, CPDismay, CPCounterweightExterior]

func getStartingRingTypes() -> Array[Script]: 
	return [RingPreserverOfTheDrowned]
