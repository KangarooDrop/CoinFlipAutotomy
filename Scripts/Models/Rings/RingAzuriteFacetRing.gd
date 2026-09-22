extends RingModel

class_name RingAzuriteFacetRing

####################################################################################################

func getLocID() -> String: return super.getLocID() + "AZURITE_FACET_RING"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "azurite_facet_ring.png"

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealAquaFortis).getName()]

####################################################################################################

func onBeforeTurnSkipped(matchState : MatchState) -> void:
	var playerModel : PlayerModel = getPlayerModel()
	var coinFaceModel : CoinFaceModel = playerModel.getCoinFaceModel()
	var coinPiecesNoSeal : Array[CoinPieceModel] = []
	for coinPieceModel : CoinPieceModel in coinFaceModel.getAllPieces():
		if coinPieceModel.hasSeal():
			continue
		coinPiecesNoSeal.append(coinPieceModel)
	if coinPiecesNoSeal.size() == 0:
		return
	var coinPieceToStamp : CoinPieceModel = coinPiecesNoSeal[RNG.getRandi() % coinPiecesNoSeal.size()]
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealAquaFortis), coinPieceToStamp)
