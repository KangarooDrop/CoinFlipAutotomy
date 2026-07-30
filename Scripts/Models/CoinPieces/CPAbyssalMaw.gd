extends CoinPieceModel

class_name CPAbyssalMaw

func getLocID() -> String: return super.getLocID() + "ABYSSAL_MAW"

func getTexturePath() -> String:
	return super.getTexturePath() + "abyssal_maw.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityMock,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData
