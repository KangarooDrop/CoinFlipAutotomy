extends Ability
class_name AbilityBurningObsession

const SPIN_MULT : float = 0.1
const SPIN_REQ : int = 30

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "BURNING_OBSESSION"

func getTexturePath() -> String:
	return super.getTexturePath() + "burning_obsession.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [str(SPIN_MULT), SPIN_REQ, ModelDB.getSealSingleton(SealAquaFortis).getName()]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() > 0:
		push_error("ERROR: Invalid num targets given to AbilityBurningObsession.activate: " + str(abilityContext.targets.size()) + " > 0.")
		return
	
	var playerModel : PlayerModel = abilityContext.getPlayerModel()
	var spinIncBase : int = int(matchState.getSpin(playerModel) * SPIN_MULT)
	var actualIncPointer : Pointer = await CmdSpin.addSpin(matchState, playerModel, spinIncBase)
	
	if actualIncPointer.val >= SPIN_REQ and not abilityContext.isCopy:
		var copyTarget : CoinPieceModel = await CmdAction.getTarget(matchState, Entities.TargetType.COIN_PIECE_ANY, playerModel)
		await CmdMatch.copyAbilityScript(matchState, copyTarget.abilityScript, abilityContext)
	else:
		var sealTarget : CoinPieceModel = await CmdAction.getTarget(matchState, Entities.TargetType.NON_SEAL_ANY, playerModel)
		if sealTarget == null:
			return
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealAquaFortis), sealTarget)
