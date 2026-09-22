extends Ability
class_name AbilityDevour

const SPIN_INC : int = 10

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "DEVOUR"

func getTexturePath() -> String:
	return super.getTexturePath() + "devour.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.COIN_PIECE_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [SPIN_INC, ModelDB.getSealSingleton(SealLead).getName()]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityDevour.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityDevour.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	await CmdSpin.addSpin(matchState, abilityContext.getPlayerModel(), SPIN_INC)
	
	var targetCoinPiece : CoinPieceModel = abilityContext.targets[0]
	if not targetCoinPiece.hasSeal():
		return
	await CmdSeal.removeSeal(matchState, targetCoinPiece)
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), targetCoinPiece)
