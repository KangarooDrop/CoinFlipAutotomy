extends Ability
class_name AbilityPlayWithYourFood

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "PLAY_WITH_YOUR_FOOD"

func getTexturePath() -> String:
	return super.getTexturePath() + "play_with_your_food.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealCrystallization).getName(), ModelDB.getSealSingleton(SealAquaFortis).getName()]

####################################################################################################

func activate(matchState : MatchState) -> void:
	if abilityContext == null:
		print("ERROR: No Ability Context given to AbilityPlayWithYourFood.activate")
		return
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityPlayWithYourFood.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityPlayWithYourFood.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	if targetCoinPieceModel.hasSeal():
		pass
		push_error("ERROR: Coin Piece with Seal given to AbilityPlayWithYourFood.activate: " + str(targetCoinPieceModel.getSealModel()) + ".")
		return
	var adjacentTarget : CoinPieceModel = RNG.getRandomAdjacentNonSeal(matchState, targetCoinPieceModel)
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCrystallization), targetCoinPieceModel, self)
	if adjacentTarget != null:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealAquaFortis), adjacentTarget, self)
