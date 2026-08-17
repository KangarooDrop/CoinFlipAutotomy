extends RingModel

class_name RingBlankBand

const SPIN_GAIN : int = 10

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BLANK_BAND"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "blank_band.png"

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_GAIN

####################################################################################################

func onAfterAbilityCountered(matchState : MatchState, _ability : Ability, _context : AbilityContext) -> void:
	await CmdSpin.addSpin(matchState, getPlayerModel(), SPIN_GAIN)

func onBeforeTurnSkipped(matchState : MatchState) -> void:
	await CmdSpin.addSpin(matchState, getPlayerModel(), SPIN_GAIN)
