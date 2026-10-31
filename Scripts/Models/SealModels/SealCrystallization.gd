extends SealModel

class_name SealCrystallization

var presentSinceStart : bool = false

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CRYSTALLIZATION"

func getTexturePath() -> String:
	return super.getTexturePath() + "crystallization.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
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

func onTurnStart(matchState : MatchState) -> bool:
	if getPlayerModel() != matchState.getActivePlayerModel():
		return false
	presentSinceStart = true
	return true

func onBeforeTurnEnd(matchState : MatchState) -> bool:
	if getPlayerModel() != matchState.getActivePlayerModel():
		return false
	if not presentSinceStart:
		return false
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	await CmdSeal.removeSeal(matchState, coinPieceModel)
	return true
