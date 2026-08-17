extends RingModel

class_name RingBowOfBellsEnd

var _canActivate : bool = true

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

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealCrystallization).getLocalizedString("name")

####################################################################################################

func onRoundStart(matchState : MatchState) -> void:
	_canActivate = true
	popNode()
	
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel == null:
		return
	
	for coinPieceModel : CoinPieceModel in playerModel.getCoinFaceModel().getAllPieces():
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCrystallization), coinPieceModel)

func onBeforeTurnEnd(matchState : MatchState) -> void:
	if not _canActivate:
		return
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel != matchState.getActivePlayerModel():
		return
	if matchState.currentTurnNumber <= matchState.NUM_TURNS_MAX - 2:
		return
	
	popNode()
	_canActivate = false
	CmdMatch.addAdditionalTurn(matchState, playerModel)
