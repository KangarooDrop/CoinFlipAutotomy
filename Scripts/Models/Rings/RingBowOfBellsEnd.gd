extends RingModel

class_name RingBowOfBellsEnd

var _canActivate : bool = true

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BOW_OF_BELLS_END"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "bow_of_bells_end.png"

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealCrystallization).getName()

####################################################################################################

func onRoundStart(matchState : MatchState) -> bool:
	_canActivate = true
	popNode()
	
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel == null:
		return true
	
	for coinPieceModel : CoinPieceModel in playerModel.getCoinFaceModel().getAllPieces():
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCrystallization), coinPieceModel, self)
	return true

func onBeforeTurnEnd(matchState : MatchState) -> bool:
	if not _canActivate:
		return false
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel != matchState.getActivePlayerModel():
		return false
	if matchState.currentTurnNumber <= matchState.NUM_TURNS_MAX - 2:
		return false
	
	popNode()
	_canActivate = false
	CmdMatch.addAdditionalTurn(matchState, playerModel)
	return true
