extends CoinPieceModel

class_name CPAllureOfFlame

func getLocID() -> String: return super.getLocID() + "ALLURE_OF_FLAME"

func getTexturePath() -> String:
	return super.getTexturePath() + "allure_of_flame.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityUntouchableHeat,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
