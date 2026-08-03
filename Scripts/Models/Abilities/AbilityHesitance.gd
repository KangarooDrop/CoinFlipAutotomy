extends Ability

class_name AbilityHesitance

func getLocID() -> String: 
	return super.getLocID() + "HESITANCE"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealQuicksliver).getLocalizedString("name")

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityHesitance.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityHesitance.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealQuicksliver), abilityContext.targets[0])
