extends SealModel

class_name SealLead

####################################################################################################

func getLocID() -> String: return super.getLocID() + "LEAD"

func getTexturePath() -> String:
	return super.getTexturePath() + "lead.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW,
	}, true)
	return baseData

####################################################################################################

func onBeforeAbilityCheck(matchState : MatchState, _ability : Ability, context : AbilityContext) -> bool:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if context.source != coinPieceModel:
		return false
	if context.isCountered:
		return false
	
	context.isCountered = true
	await CmdSeal.removeSeal(matchState, coinPieceModel)
	return true
