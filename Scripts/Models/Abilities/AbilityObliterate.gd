extends Ability
class_name AbilityObliterate

func getLocID() -> String: 
	return super.getLocID() + "OBLITERATE"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.AbilityTargetType.FINGER_FRIENDLY,
	}, true)
	return baseData

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityObliterate.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is FingerModel:
		push_error("ERROR: Invalid target given to AbilityObliterate.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var fingerModel : FingerModel = abilityContext.targets[0]
	await CmdFinger.destroyFinger(matchState, fingerModel)
