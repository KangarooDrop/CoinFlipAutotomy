extends Ability
class_name AbilityPlungeIntoDarkness

const SPIN_DEC : int = 20
const SPIN_INC : int = 20

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "PLUNGE_INTO_DARKNESS"

func getTexturePath() -> String:
	return super.getTexturePath() + "plunge_into_darkness.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [SPIN_DEC, SPIN_INC]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() > 0:
		push_error("ERROR: Invalid num targets given to AbilityPlungeIntoDarkness.activate: " + str(abilityContext.targets.size()) + " > 0.")
		return
	
	for playerModel : PlayerModel in matchState.getAllPlayerModels():
		await CmdSpin.addSpin(matchState, playerModel, -SPIN_DEC)
	
	var playerModel : PlayerModel = abilityContext.getPlayerModel()
	var coinPieceModelToRemove : CoinPieceModel = await matchState.getTarget(Entities.TargetType.SEAL_ANY, playerModel)
	if coinPieceModelToRemove == null:
		return
	
	var isOwned : bool = coinPieceModelToRemove.getPlayerModel() == playerModel
	await CmdSeal.removeSeal(matchState, coinPieceModelToRemove)
	
	if isOwned:
		await CmdSpin.addSpin(matchState, playerModel, SPIN_INC)
	else:
		coinPieceModelToRemove = await matchState.getTarget(Entities.TargetType.SEAL_ANY, playerModel)
		if coinPieceModelToRemove == null:
			return
		await CmdSeal.removeSeal(matchState, coinPieceModelToRemove)
