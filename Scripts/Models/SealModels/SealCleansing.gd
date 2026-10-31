extends SealModel

class_name SealCleansing

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CLEANSING"

func getTexturePath() -> String:
	return super.getTexturePath() + "cleansing.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.ORANGE,
	}, true)
	return baseData

####################################################################################################

func onBeforeTurnEnd(matchState : MatchState) -> bool:
	if matchState.getActivePlayerModel() != getPlayerModel():
		return false
	var coinPieceModel : CoinPieceModel = getCoinPieceModel()
	if coinPieceModel == null:
		return false
	var coinFaceModel : CoinFaceModel = coinPieceModel.getCoinFaceModel()
	if coinFaceModel == null:
		return false
	
	var coinPieceSocketIndex : Entities.CoinPieceSocketIndex = coinPieceModel.getSocketIndex()
	for adjacentSocketIndex : Entities.CoinPieceSocketIndex in Entities.CoinPieceSocketScript.getAllAdjacent(coinPieceSocketIndex):
		var adjacentCoinPieceModel : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(adjacentSocketIndex)
		if adjacentCoinPieceModel == null:
			continue
		await CmdSeal.removeSeal(matchState, adjacentCoinPieceModel)
	await CmdSeal.removeSeal(matchState, coinPieceModel)
	return true
