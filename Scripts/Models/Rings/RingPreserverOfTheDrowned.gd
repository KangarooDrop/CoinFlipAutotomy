extends RingModel

class_name RingPreserverOfTheDrowned

const SPIN_INC : int = 50

var _canActivate : bool = true

####################################################################################################

func getLocID() -> String: return super.getLocID() + "PRESERVER_OF_THE_DROWNED"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "preserver_of_the_drowned.png"

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_INC

####################################################################################################

func onRoundStart(_matchState : MatchState) -> bool:
	_canActivate = true
	return true

func onAfterSpinChanged(matchState : MatchState, playerModel : PlayerModel, _amount : int, _source : RefCounted) -> bool:
	if not _canActivate:
		return false
	
	var ownPlayerModel : PlayerModel = getPlayerModel()
	if playerModel != ownPlayerModel:
		return false
	
	if matchState.getSpin(ownPlayerModel) > 0:
		return false
	
	await CmdSpin.addSpin(matchState, playerModel, SPIN_INC, self)
	_canActivate = false
	popNode()
	return true
