extends SealModel

class_name SealQuicksilver

const SPIN_LOSS_BASE : int = 10

####################################################################################################

func getLocID() -> String: return super.getLocID() + "QUICKSILVER"

func getTexturePath() -> String:
	return super.getTexturePath() + "quicksilver.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_LOSS_BASE

####################################################################################################

func onAfterAbilityActivated(matchState : MatchState, ability : Ability) -> bool:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if coinPieceModel == null:
		return false
	var playerModel : PlayerModel = coinPieceModel.getPlayerModel()
	if playerModel == null:
		return false
	if ability.abilityContext.source != coinPieceModel:
		return false
	
	await CmdSpin.addSpin(matchState, playerModel, -SPIN_LOSS_BASE, self)
	return true
