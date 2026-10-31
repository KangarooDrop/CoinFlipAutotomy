extends SealModel

class_name SealCopper

const SPIN_INC : int = 5
const SPIN_DEC : int = 30

var _wasAbilityActivated : bool = false

####################################################################################################

func getLocID() -> String: return super.getLocID() + "COPPER"

func getTexturePath() -> String:
	return super.getTexturePath() + "copper.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW_DARK,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [SPIN_DEC, SPIN_INC]

####################################################################################################

func onAfterAbilityActivated(_matchState : MatchState, _ability : Ability, context : AbilityContext) -> bool:
	if context.source != getCoinPieceModel():
		return false
	
	_wasAbilityActivated = true
	return true

func onBeforeTurnEnd(matchState : MatchState) -> bool:
	var ownPlayerModel : PlayerModel = getPlayerModel()
	if matchState.getActivePlayerModel() != ownPlayerModel:
		return false
	
	if not _wasAbilityActivated:
		await CmdSpin.addSpin(matchState, ownPlayerModel, SPIN_INC)
	else:
		await CmdSpin.addSpin(matchState, ownPlayerModel, -SPIN_DEC)
		await CmdSeal.removeSeal(matchState, getCoinPieceModel())
	return true
