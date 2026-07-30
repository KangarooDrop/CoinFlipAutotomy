extends Ability

class_name AbilityMock

func getLocID() -> String: 
	return super.getLocID() + "MOCK"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.AbilityTargetType.COIN_PIECE_ENEMY,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealBlackSulfur).getLocalizedString("name")

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityMock.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityMock.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.setSeal(ModelDB.getSeal(SealBlackSulfur), abilityContext.targets[0])
