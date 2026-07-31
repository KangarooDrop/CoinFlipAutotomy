extends SealModel

class_name SealLead

func getLocID() -> String: return super.getLocID() + "LEAD"

func getTexturePath() -> String:
	return super.getTexturePath() + "sigil_lead.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW,
	}, true)
	return baseData

func onBeforeAbilityCheck(matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if context.source == coinPieceModel:
		if not context.isCountered:
			context.isCountered = true
			CmdSeal.removeSeal(matchState, coinPieceModel)
