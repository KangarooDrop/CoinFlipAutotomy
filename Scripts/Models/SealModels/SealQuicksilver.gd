extends SealModel

class_name SealQuicksliver

const SPIN_LOSS_BASE : int = 12

func getLocID() -> String: return super.getLocID() + "QUICKSILVER"

func getTexturePath() -> String:
	return super.getTexturePath() + "sigil_quicksilver.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_LOSS_BASE

func onAfterAbilityActivated(matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if coinPieceModel == null:
		return
	var playerModel : PlayerModel = coinPieceModel.getPlayerModel()
	if playerModel == null:
		return
	
	if context.source == coinPieceModel:
		CmdSpin.addSpin(matchState, playerModel, -SPIN_LOSS_BASE)
