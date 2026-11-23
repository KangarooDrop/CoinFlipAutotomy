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

func onBeforeAbilityCheck(matchState : MatchState, ability : Ability) -> bool:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if ability.abilityContext.source != coinPieceModel:
		return false
	if ability.abilityContext.isCountered:
		return false
	
	ability.abilityContext.isCountered = true
	await CmdSeal.removeSeal(matchState, coinPieceModel, self)
	return true
