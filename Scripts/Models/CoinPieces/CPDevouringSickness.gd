extends CoinPieceModel

class_name CPDevouringSickness

func getLocID() -> String: return super.getLocID() + "DEVOURING_SICKNESS"

func getTexturePath() -> String:
	return super.getTexturePath() + "devouring_sickness.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityConsumption,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
