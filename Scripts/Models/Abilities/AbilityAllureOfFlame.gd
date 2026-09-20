extends Ability
class_name AbilityAllureOfFlame

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "ALLURE_OF_FLAME"

func getTexturePath() -> String:
	return super.getTexturePath() + "allure_of_flame.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealCopper).getName()

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityAllureOfFlame.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityAllureOfFlame.activate: " + str(abilityContext.targets[0]) + ".")
		return
	if abilityContext.targets[0].getSealModel() != null:
		push_error("ERROR: Coin Node without a seal given to AbilityAllureOfFlame.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.setSeal(matchState, ModelDB.getSeal(SealCopper), abilityContext.targets[0])
