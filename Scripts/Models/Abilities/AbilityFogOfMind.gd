extends Ability
class_name AbilityFogOfMind

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "FOG_OF_MIND"

func getTexturePath() -> String:
	return super.getTexturePath() + "fog_of_mind.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % \
		[ModelDB.getSealSingleton(SealLead).getName(), ModelDB.getSealSingleton(SealBlackSulfur).getName(), \
		ModelDB.getSealSingleton(SealCrystallization).getName()]

####################################################################################################

func _getRandomAdjacentNonSeal(coinPieceModel : CoinPieceModel) -> CoinPieceModel:
	if coinPieceModel == null:
		return null
	var adjacentCoinPieceModels : Array[CoinPieceModel] = coinPieceModel.getCoinFaceModel().getAdjacentCoinPieces(coinPieceModel)
	for i in range(adjacentCoinPieceModels.size()-1, -1, -1):
		if adjacentCoinPieceModels[i].getSealModel() == null:
			continue
		adjacentCoinPieceModels.remove_at(i)
	if adjacentCoinPieceModels.size() > 0:
		return adjacentCoinPieceModels[RNG.getRandi() % adjacentCoinPieceModels.size()]
	else:
		return null

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityFogOfMind.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), targetCoinPieceModel)
	
	var adjacentTarget : CoinPieceModel = _getRandomAdjacentNonSeal(targetCoinPieceModel)
	if adjacentTarget != null:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealBlackSulfur), adjacentTarget)
	
	var sourceCoinPieceModel : CoinPieceModel = null
	if abilityContext.source is CoinPieceModel:
		sourceCoinPieceModel = abilityContext.source
	if sourceCoinPieceModel != null:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCrystallization), sourceCoinPieceModel)
