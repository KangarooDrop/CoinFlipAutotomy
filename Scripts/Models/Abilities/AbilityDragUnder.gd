extends Ability

class_name AbilityDragUnder

func getLocID() -> String: 
	return super.getLocID() + "DRAG_UNDER"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
	}, true)
	return baseData

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 0:
		push_error("ERROR: Invalid num targets given to AbilityDragUnder.activate: " + str(abilityContext.targets.size()) + " != 0.")
		return
	
	var playerModel : PlayerModel = getPlayerModel(abilityContext)
	var opponentPlayerModel : PlayerModel = matchState.getOtherPlayerModel(playerModel)
	var spinDiff : int = abs(matchState.getSpin(opponentPlayerModel) - matchState.getSpin(playerModel))
	await CmdSpin.addSpin(matchState, opponentPlayerModel, -spinDiff/2)
