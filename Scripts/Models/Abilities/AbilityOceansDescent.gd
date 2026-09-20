extends Ability
class_name AbilityOceansDescent

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "OCEANS_DESCENT"

func getTexturePath() -> String:
	return super.getTexturePath() + "oceans_descent.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealBlackSulfur).getName()

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityOceansDescent.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityOceansDescent.activate: " + str(abilityContext.targets[0]) + ".")
		return
	if abilityContext.targets[0].getSealModel() != null:
		push_error("ERROR: Coin Node without a seal given to AbilityOceansDescent.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.setSeal(matchState, ModelDB.getSeal(SealBlackSulfur), abilityContext.targets[0])
