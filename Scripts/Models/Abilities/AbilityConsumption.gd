extends Ability
class_name AbilityConsumption

const SPIN_INC : int = 20

func getLocID() -> String: 
	return super.getLocID() + "CONSUMPTION"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_INC

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 0:
		push_error("ERROR: Invalid num targets given to AbilityDragUnder.activate: " + str(abilityContext.targets.size()) + " != 0.")
		return
	
	await CmdSpin.addSpin(matchState, getPlayerModel(abilityContext), SPIN_INC)
