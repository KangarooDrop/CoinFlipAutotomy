extends Ability
class_name AbilityFormlessLikeWater

const SPIN_DEC : int = 10

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "FORMLESS_LIKE_WATER"

func getTexturePath() -> String:
	return super.getTexturePath() + "formless_like_water.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.COIN_PIECE_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_DEC

####################################################################################################

func activate(matchState : MatchState) -> void:
	if abilityContext == null:
		print("ERROR: No Ability Context given to AbilityFormlessLikeWater.activate")
		return
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityFormlessLikeWater.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityFormlessLikeWater.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var abilityPlayerModel : PlayerModel = abilityContext.getPlayerModel()
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	var targetPlayerModel : PlayerModel = targetCoinPieceModel.getPlayerModel()
	
	if targetPlayerModel == abilityPlayerModel:
		await CmdSeal.removeSeal(matchState, targetCoinPieceModel, self)
	else:
		await CmdSpin.addSpin(matchState, targetPlayerModel, -SPIN_DEC, self)
	
	if not abilityContext.isCopy:
		await CmdMatch.copyAbilityScriptNewContext(matchState, targetCoinPieceModel.abilityScript, abilityContext)
