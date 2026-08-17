extends DemonModel

class_name DemonEnvy

func getLocID() -> String: return super.getLocID() + "ENVY"

func getDirName() -> String:
	return "envy"

func getStartingCoinPieceTypes() -> Array[Script]: 
	return [CPDrownardsVictim, 
		CPOceansDescent, CPDismay, CPSirensCall]

func getStartingRingTypes() -> Array[Script]: 
	return [RingDualTungstenSignate]
