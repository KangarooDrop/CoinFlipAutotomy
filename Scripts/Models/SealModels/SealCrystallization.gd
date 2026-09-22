extends SealModel

class_name SealCrystallization

var presentSinceStart : bool = false

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CRYSTALLIZATION"

func getTexturePath() -> String:
	return super.getTexturePath() + "crystallization.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.YELLOW,
	}, true)
	return baseData

####################################################################################################

func canActivateAbilityOfCoinPiece(_matchState : MatchState, coinPieceModel : CoinPieceModel) -> bool:
	if coinPieceModel == getCoinPieceModel():
		return false
	return true

func onTurnStart(matchState : MatchState) -> void:
	if getPlayerModel() != matchState.getActivePlayerModel():
		return
	presentSinceStart = true

func onBeforeTurnEnd(matchState : MatchState) -> void:
	if getPlayerModel() != matchState.getActivePlayerModel():
		return
	if not presentSinceStart:
		return
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	await CmdSeal.removeSeal(matchState, coinPieceModel)
