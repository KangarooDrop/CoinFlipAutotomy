extends Ability
class_name AbilityPhaseChange

const SPIN_DEC : int = 15

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "PHASE_CHANGE"

func getTexturePath() -> String:
	return super.getTexturePath() + "phase_change.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_DEC

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 0:
		push_error("ERROR: Invalid num targets given to AbilityPhaseChange.activate: " + str(abilityContext.targets.size()) + " != 0.")
		return
	
	var playerModel : PlayerModel = abilityContext.getPlayerModel()
	if not abilityContext.isCopy:
		var opponentModel : PlayerModel = matchState.getOtherPlayerModel(playerModel)
		await CmdSpin.addSpin(matchState, opponentModel, -SPIN_DEC)
	else:
		var coinPieceToBreak : CoinPieceModel = await CmdAction.getTarget(matchState, Entities.TargetType.SEAL_ANY, playerModel)
		if coinPieceToBreak == null:
			return
		await CmdSeal.removeSeal(matchState, coinPieceToBreak)
