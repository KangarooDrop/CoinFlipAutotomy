extends CoinPieceModel

class_name CPDrownardsVictim

func getLocID() -> String: return super.getLocID() + "DROWNARDS_VICTIM"

func getTexturePath() -> String:
	return super.getTexturePath() + "drownards_victim.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityDragUnder,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData
