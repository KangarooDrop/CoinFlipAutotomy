extends Ability
class_name AbilitySaltTheEarth

const SPIN_DEC : int = 10

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "SALT_THE_EARTH"

func getTexturePath() -> String:
	return super.getTexturePath() + "salt_the_earth.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealArsenic).getName(), SPIN_DEC]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilitySaltTheEarth.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilitySaltTheEarth.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	if targetCoinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with Seal given to AbilitySaltTheEarth.activate: " + str(targetCoinPieceModel.getSealModel()) + ".")
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealArsenic), targetCoinPieceModel)
	
	var playerModel : PlayerModel = abilityContext.getPlayerModel()
	await CmdSpin.addSpin(matchState, playerModel, -SPIN_DEC)
