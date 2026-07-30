extends SealModel

class_name SealCleansing

func getLocID() -> String: return super.getLocID() + "CLEANSING"

func getTexturePath() -> String:
	return super.getTexturePath() + "sigil_cleansing.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.ORANGE,
	}, true)
	return baseData

func onBeforeTurnEnd(matchState : MatchState) -> void:
	if matchState.getActivePlayerModel() != getPlayerModel():
		return
	if _coinPieceModel == null:
		return
	var coinFaceModel : CoinFaceModel = _coinPieceModel.getCoinFaceModel()
	if coinFaceModel == null:
		return
	var coinPieceSocketIndex : Entities.CoinPieceSocketIndex = getCoinPieceModel().getSocketIndex()
	for adjacentSocketIndex : Entities.CoinPieceSocketIndex in Entities.CoinPieceSocketScript.getAllAdjacent(coinPieceSocketIndex):
		var adjacentCoinPieceModel : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(adjacentSocketIndex)
		if adjacentCoinPieceModel == null:
			continue
		await CmdSeal.removeSeal(adjacentCoinPieceModel)
	await CmdSeal.removeSeal(_coinPieceModel)
