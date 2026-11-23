extends RingModel

class_name RingBlankBand

const SPIN_GAIN : int = 10

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BLANK_BAND"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "blank_band.png"

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_GAIN

####################################################################################################

func onAfterAbilityCountered(matchState : MatchState, _ability : Ability) -> bool:
	await CmdSpin.addSpin(matchState, getPlayerModel(), SPIN_GAIN, self)
	return true

func onBeforeTurnSkipped(matchState : MatchState) -> bool:
	await CmdSpin.addSpin(matchState, getPlayerModel(), SPIN_GAIN, self)
	return true
