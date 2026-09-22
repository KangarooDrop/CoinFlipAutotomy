extends SealModel

class_name SealArsenic

const SPIN_DEC : int = 20

####################################################################################################

func getLocID() -> String: return super.getLocID() + "ARSENIC"

func getTexturePath() -> String:
	return super.getTexturePath() + "arsenic.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.PURPLE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_DEC

####################################################################################################

func onAfterAbilityActivated(matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if context.source != coinPieceModel:
		return
	var playerModel : PlayerModel = getPlayerModel()
	await CmdSeal.removeSeal(matchState, coinPieceModel)
	await CmdSpin.addSpin(matchState, playerModel, -SPIN_DEC)
