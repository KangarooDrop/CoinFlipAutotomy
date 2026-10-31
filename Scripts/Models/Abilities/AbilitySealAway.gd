extends Ability
class_name AbilitySealAway

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "SEAL_AWAY"

func getTexturePath() -> String:
	return super.getTexturePath() + "seal_away.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NON_SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealWax).getName()]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilitySealAway.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilitySealAway.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	if targetCoinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with Seal given to AbilitySealAway.activate: " + str(targetCoinPieceModel.getSealModel()) + ".")
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealWax), targetCoinPieceModel)
	
	var sourceCoinPieceModel : CoinPieceModel = null
	if abilityContext.source is CoinPieceModel:
		sourceCoinPieceModel = abilityContext.source
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealWax), sourceCoinPieceModel)
