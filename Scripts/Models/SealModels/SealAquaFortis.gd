extends SealModel

class_name SealAquaFortis

const SPIN_GAIN_BASE : int = 5

####################################################################################################

func getLocID() -> String: return super.getLocID() + "AQUA_FORTIS"

func getTexturePath() -> String:
	return super.getTexturePath() + "aqua_fortis.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.RED,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_GAIN_BASE

####################################################################################################

func onTurnStart(matchState : MatchState) -> void:
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel != matchState.getActivePlayerModel():
		return
	
	await CmdSpin.addSpin(matchState, playerModel, SPIN_GAIN_BASE)
