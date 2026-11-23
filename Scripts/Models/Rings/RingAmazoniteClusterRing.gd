extends RingModel

class_name RingAmazoniteClusterRing

const NUM_SEALS_PER_PLAYER : int = 2

####################################################################################################

func getLocID() -> String: return super.getLocID() + "AMAZONITE_CLUSTER_RING"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "amazonite_cluster_ring.png"

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealLead).getName(), NUM_SEALS_PER_PLAYER]

####################################################################################################

func onRoundStart(matchState : MatchState) -> bool:
	popNode()
	
	var randomNonSeals : Array[CoinPieceModel] = []
	for playerModel : PlayerModel in matchState.getAllPlayerModels():
		var coinFaceModel : CoinFaceModel = playerModel.getCoinFaceModel()
		if coinFaceModel == null:
			continue
		randomNonSeals.append_array(RNG.getNRandomCoinPiecesNonSeal(matchState, coinFaceModel, NUM_SEALS_PER_PLAYER))
	
	for coinPieceModel : CoinPieceModel in randomNonSeals:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), coinPieceModel, self)
	return true
