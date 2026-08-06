extends SealModel

class_name SealCopper

const SPIN_INC : int = 5
const SPIN_DEC : int = 30

var _wasAbilityActivated : bool = false

####################################################################################################

func getLocID() -> String: return super.getLocID() + "COPPER"

func getTexturePath() -> String:
	return super.getTexturePath() + "sigil_copper.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW_DARK,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [SPIN_DEC, SPIN_INC]

####################################################################################################

func onAfterAbilityActivated(_matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	if context.source != getCoinPieceModel():
		return
	
	_wasAbilityActivated = true

func onBeforeTurnEnd(matchState : MatchState) -> void:
	var ownPlayerModel : PlayerModel = getPlayerModel()
	if matchState.getActivePlayerModel() != ownPlayerModel:
		return
	
	if not _wasAbilityActivated:
		CmdSpin.addSpin(matchState, ownPlayerModel, SPIN_INC)
	else:
		CmdSpin.addSpin(matchState, ownPlayerModel, -SPIN_DEC)
		CmdSeal.removeSeal(matchState, getCoinPieceModel())
