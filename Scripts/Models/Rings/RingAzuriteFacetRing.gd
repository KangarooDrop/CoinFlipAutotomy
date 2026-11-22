extends RingModel

class_name RingAzuriteFacetRing

####################################################################################################

func getLocID() -> String: return super.getLocID() + "AZURITE_FACET_RING"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "azurite_facet_ring.png"

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealAquaFortis).getName()]

####################################################################################################

func onBeforeTurnSkipped(matchState : MatchState) -> bool:
	var playerModel : PlayerModel = getPlayerModel()
	if playerModel == null:
		return false
	var coinFaceModel : CoinFaceModel = playerModel.getCoinFaceModel()
	if coinFaceModel == null:
		return false
	var randomNonSeal : CoinPieceModel = RNG.getRandomCoinPieceNonSeal(matchState, coinFaceModel)
	if randomNonSeal == null:
		return false
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealAquaFortis), randomNonSeal)
	return true
