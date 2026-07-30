extends FingerRingModel

class_name RingBowOfBellsEnd

var _canActivate : bool = true
var _hasSkipped : bool = false

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BOW_OF_BELLS_END"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "bow_of_bells_end.png"

####################################################################################################

func onRoundStart(_matchState : MatchState) -> void:
	_canActivate = true
	_hasSkipped = false

func onTurnStart(matchState : MatchState) -> void:
	if getPlayerModel() != matchState.getActivePlayerModel():
		return
	if _hasSkipped:
		return
	
	_hasSkipped = true
	CmdAction.skipTurn()

func onBeforeTurnEnd(matchState : MatchState) -> void:
	if not _canActivate:
		return
	if getPlayerModel() != matchState.getActivePlayerModel():
		return
	if matchState.currentTurnNumber <= matchState.NUM_TURNS_MAX - 2:
		return
	
	_canActivate = false
	matchState.addAdditionalTurn(getPlayerModel())
