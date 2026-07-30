extends CoinPieceModel

class_name CPDismay

func getLocID() -> String: return super.getLocID() + "DISMAY"

func getTexturePath() -> String:
	return super.getTexturePath() + "dismay.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityHesitance,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
