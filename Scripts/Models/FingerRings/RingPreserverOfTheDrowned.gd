extends FingerRingModel

class_name RingPreserverOfTheDrowned

const SPIN_INC : int = 50

var _canActivate : bool = true

####################################################################################################

func getLocID() -> String: return super.getLocID() + "PRESERVER_OF_THE_DROWNED"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "preserver_of_the_drowned.png"

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_INC

####################################################################################################

func onRoundStart(_matchState : MatchState) -> void:
	_canActivate = true

func onAfterSpinChanged(matchState : MatchState, playerModel : PlayerModel) -> void:
	if not _canActivate:
		return
	
	var ownPlayerModel : PlayerModel = getPlayerModel()
	if playerModel != ownPlayerModel:
		return
	
	if matchState.getSpin(ownPlayerModel) > 0:
		return
	
	await CmdSpin.addSpin(matchState, playerModel, SPIN_INC)
	_canActivate = false
	popNode()
