extends SealModel

class_name SealArsenic

const SPIN_DEC : int = 20

####################################################################################################

func getLocID() -> String: return super.getLocID() + "ARSENIC"

func getTexturePath() -> String:
	return super.getTexturePath() + "arsenic.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.PURPLE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_DEC

####################################################################################################

func onAfterAbilityActivated(matchState : MatchState, ability : Ability) -> bool:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if ability.abilityContext.source != coinPieceModel:
		return false
	var playerModel : PlayerModel = getPlayerModel()
	await CmdSeal.removeSeal(matchState, coinPieceModel, self)
	await CmdSpin.addSpin(matchState, playerModel, -SPIN_DEC, self)
	return true
