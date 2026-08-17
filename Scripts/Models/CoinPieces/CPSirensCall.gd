extends CoinPieceModel

class_name CPSirensCall

func getLocID() -> String: return super.getLocID() + "SIRENS_CALL"

func getTexturePath() -> String:
	return super.getTexturePath() + "sirens_call.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		ABILITY_SCRIPT_KEY : AbilityJoinMe,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData
