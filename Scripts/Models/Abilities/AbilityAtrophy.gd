extends Ability
class_name AbilityAtrophy

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "ATROPHY"

func getTexturePath() -> String:
	return super.getTexturePath() + "atrophy.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % ModelDB.getSealSingleton(SealLead).getName()

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityAtrophy.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityAtrophy.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), abilityContext.targets[0])
