extends Ability
class_name AbilityUntouchableHeat

func getLocID() -> String: 
	return super.getLocID() + "UNTOUCHABLE_HEAT"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealCopper).getLocalizedString("name")

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityRipTide.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityRipTide.activate: " + str(abilityContext.targets[0]) + ".")
		return
	if abilityContext.targets[0].getSealModel() != null:
		push_error("ERROR: Coin Node without a seal given to AbilityRipTide.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.setSeal(matchState, ModelDB.getSeal(SealCopper), abilityContext.targets[0])
