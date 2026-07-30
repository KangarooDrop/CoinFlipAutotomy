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

func onBeforeAbilityCheck(_matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	if context.source == getCoinPieceModel():
		if not context.isCountered:
			context.isCountered = true
			getCoinPieceModel().removeSealModel()
