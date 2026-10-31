extends SealModel

class_name SealBlackSulfur

const SPIN_LOSS_BASE : int = 5

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BLACK_SULFUR"

func getTexturePath() -> String:
	return super.getTexturePath() + "black_sulfur.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.PURPLE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_LOSS_BASE

####################################################################################################

func onTurnStart(matchState : MatchState) -> bool:
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel != matchState.getActivePlayerModel():
		return false
	
	popNode()
	await CmdSpin.addSpin(matchState, playerModel, -SPIN_LOSS_BASE)
	return true
