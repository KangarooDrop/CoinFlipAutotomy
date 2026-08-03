extends CoinPieceModel

class_name CPCounterweightExterior

func getLocID() -> String: return super.getLocID() + "COUNTERWEIGHT_EXTERIOR"

func getTexturePath() -> String:
	return super.getTexturePath() + "counterweight_exterior.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : null,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
