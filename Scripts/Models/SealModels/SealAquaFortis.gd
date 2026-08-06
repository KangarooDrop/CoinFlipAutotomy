extends SealModel

class_name SealAquaFortis

const SPIN_LOSS_BASE : int = 8

func getLocID() -> String: return super.getLocID() + "AQUA_FORTIS"

func getTexturePath() -> String:
	return super.getTexturePath() + "sigil_aqua_fortis.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.PURPLE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_LOSS_BASE

func onTurnStart(matchState : MatchState) -> void:
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel == matchState.getActivePlayerModel():
		var newSpin : int = matchState.getSpin(playerModel) - SPIN_LOSS_BASE
		matchState.setSpin(playerModel, newSpin) 
