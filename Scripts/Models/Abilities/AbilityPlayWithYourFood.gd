extends Ability
class_name AbilityPlayWithYourFood

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "PLAY_WITH_YOUR_FOOD"

func getTexturePath() -> String:
	return super.getTexturePath() + "play_with_your_food.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.COIN_PIECE_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealCrystallization).getName(), ModelDB.getSealSingleton(SealAquaFortis).getName()]

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
		push_error("ERROR: Invalid num targets given to AbilityPlayWithYourFood.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	var adjacentTarget : CoinPieceModel = _getRandomAdjacentNonSeal(targetCoinPieceModel)
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), targetCoinPieceModel)
	if adjacentTarget != null:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealAquaFortis), adjacentTarget)
