extends Ability
class_name AbilityIWillHaveYou

const SPIN_INC : int = 15

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "I_WILL_HAVE_YOU"

func getTexturePath() -> String:
	return super.getTexturePath() + "i_will_have_you.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_INC

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	var playerModel : PlayerModel = abilityContext.getPlayerModel()
	if not abilityContext.isCopy:
		var copyTarget : CoinPieceModel = await CmdAction.getTarget(matchState, Entities.TargetType.SEAL_ANY, playerModel)
		if copyTarget == null:
			return
		await CmdMatch.copyAbilityScript(matchState, copyTarget.abilityScript, abilityContext)
	else:
		await CmdSpin.addSpin(matchState, playerModel, SPIN_INC)
