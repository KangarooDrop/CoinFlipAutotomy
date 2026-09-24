extends Ability
class_name AbilityFlaringEmotions

const SPIN_INC : int = 30

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "FLARING_EMOTIONS"

func getTexturePath() -> String:
	return super.getTexturePath() + "flaring_emotions.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ENEMY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealAquaFortis).getName(), SPIN_INC]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityFlaringEmotions.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityFlaringEmotions.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	if targetCoinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with Seal given to AbilityFlaringEmotions.activate: " + str(targetCoinPieceModel) + ".")
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealAquaFortis), targetCoinPieceModel)
	
	var playerModel : PlayerModel = abilityContext.getPlayerModel()
	await CmdSpin.addSpin(matchState, playerModel, SPIN_INC)
