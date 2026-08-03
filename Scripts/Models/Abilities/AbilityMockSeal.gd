extends Ability

class_name AbilityMockSeal

func getLocID() -> String: 
	return super.getLocID() + "MOCK_SEAL"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.SEAL_ANY,
	}, true)
	return baseData

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityMockSeal.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityMockSeal.activate: " + str(abilityContext.targets[0]) + ".")
		return
	if abilityContext.targets[0].getSealModel() == null:
		push_error("ERROR: Coin Node without a seal given to AbilityMockSeal.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.removeSeal(matchState, abilityContext.targets[0])
