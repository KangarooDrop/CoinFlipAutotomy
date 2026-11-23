extends Ability
class_name AbilityFogOfMind

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "FOG_OF_MIND"

func getTexturePath() -> String:
	return super.getTexturePath() + "fog_of_mind.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
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

func activate(matchState : MatchState) -> void:
	if abilityContext == null:
		print("ERROR: No Ability Context given to AbilityFogOfMind.activate")
		return
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityFogOfMind.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityFogOfMind.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	if targetCoinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with Seal given to AbilityFogOfMind.activate: " + str(targetCoinPieceModel.getSealModel()) + ".")
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), targetCoinPieceModel, self)
	
	var adjacentTarget : CoinPieceModel = RNG.getRandomAdjacentNonSeal(matchState, targetCoinPieceModel)
	if adjacentTarget != null:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealBlackSulfur), adjacentTarget, self)
	
	var sourceCoinPieceModel : CoinPieceModel = null
	if abilityContext.source is CoinPieceModel:
		sourceCoinPieceModel = abilityContext.source
	if sourceCoinPieceModel != null and not sourceCoinPieceModel.hasSeal():
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCrystallization), sourceCoinPieceModel, self)
