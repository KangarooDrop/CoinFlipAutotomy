extends SealModel

class_name SealWax

####################################################################################################

func getLocID() -> String: return super.getLocID() + "WAX"

func getTexturePath() -> String:
	return super.getTexturePath() + "wax.png"

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

func onBeforeTurnSkipped(matchState : MatchState) -> void:
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if not matchState.getActivePlayerModel() == coinPieceModel.getPlayerModel():
		return
	await CmdSeal.removeSeal(matchState, coinPieceModel)
