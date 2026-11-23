extends SealModel

class_name SealAquaFortis

const SPIN_GAIN_BASE : int = 5

####################################################################################################

func getLocID() -> String: return super.getLocID() + "AQUA_FORTIS"

func getTexturePath() -> String:
	return super.getTexturePath() + "aqua_fortis.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.RED,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_GAIN_BASE

####################################################################################################

func onTurnStart(matchState : MatchState) -> bool:
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel != matchState.getActivePlayerModel():
		return false
	
	popNode()
	await CmdSpin.addSpin(matchState, playerModel, SPIN_GAIN_BASE, self)
	return true
