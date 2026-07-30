extends CoinPieceModel

class_name CPAtrophy

func getLocID() -> String: return super.getLocID() + "ATROPHY"

func getTexturePath() -> String:
	return super.getTexturePath() + "atrophy.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityStoppage,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
