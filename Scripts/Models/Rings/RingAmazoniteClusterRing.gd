extends RingModel

class_name RingAmazoniteClusterRing

const NUM_SEALS_PER_PLAYER : int = 2

####################################################################################################

func getLocID() -> String: return super.getLocID() + "AMAZONITE_CLUSTER_RING"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "amazonite_cluster_ring.png"

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealLead).getLocalizedString("name"), NUM_SEALS_PER_PLAYER]

####################################################################################################

func onRoundStart(matchState : MatchState) -> void:
	popNode()
	
	var playerModelToCoinPieces : Dictionary[PlayerModel, Array] = {}
	for playerModel : PlayerModel in matchState.getAllPlayerModels():
		playerModelToCoinPieces[playerModel] = playerModel.getCoinFaceModel().getAllPieces()
		for i in range(playerModelToCoinPieces[playerModel].size()-1, -1, -1):
			if playerModelToCoinPieces[playerModel][i].getSealModel() != null:
				playerModelToCoinPieces[playerModel].remove_at(i)
		while playerModelToCoinPieces[playerModel].size() > NUM_SEALS_PER_PLAYER:
			var index : int = RNG.getRandi() % playerModelToCoinPieces[playerModel].size()
			playerModelToCoinPieces[playerModel].remove_at(index)
	
	for playerModel : PlayerModel in matchState.getAllPlayerModels():
		for coinPieceModel : CoinPieceModel in playerModelToCoinPieces[playerModel]:
			await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), coinPieceModel)
