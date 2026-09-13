extends SealModel

class_name SealLead

func getLocID() -> String: return super.getLocID() + "LEAD"

func getTexturePath() -> String:
	return super.getTexturePath() + "lead.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW,
	}, true)
	return baseData

func onBeforeAbilityCheck(matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if context.source != coinPieceModel:
		return
	if context.isCountered:
		return
	
	context.isCountered = true
	await CmdSeal.removeSeal(matchState, coinPieceModel)
