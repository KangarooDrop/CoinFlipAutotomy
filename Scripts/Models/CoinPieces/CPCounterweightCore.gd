extends CoinPieceModel

class_name CPCounterweightCore

func getLocID() -> String: return super.getLocID() + "COUNTERWEIGHT_CORE"

func getTexturePath() -> String:
	return super.getTexturePath() + "counterweight_core.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : null,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData
