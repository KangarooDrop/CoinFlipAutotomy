extends CoinPieceModel

class_name CPOceansDescent

func getLocID() -> String: return super.getLocID() + "OCEANS_DESCENT"

func getTexturePath() -> String:
	return super.getTexturePath() + "oceans_descent.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityDragUnder,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
