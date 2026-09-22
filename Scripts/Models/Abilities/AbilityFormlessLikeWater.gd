extends Ability
class_name AbilityFormlessLikeWater

const SPIN_DEC : int = 10

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "FORMLESS_LIKE_WATER"

func getTexturePath() -> String:
	return super.getTexturePath() + "formless_like_water.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.COIN_PIECE_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_DEC

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityFormlessLikeWater.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	
	var abilityPlayerModel : PlayerModel = abilityContext.getPlayerModel()
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	var targetPlayerModel : PlayerModel = targetCoinPieceModel.getPlayerModel()
	
	if targetPlayerModel == abilityPlayerModel:
		await CmdSeal.removeSeal(matchState, targetCoinPieceModel)
	else:
		await CmdSpin.addSpin(matchState, targetPlayerModel, -SPIN_DEC)
	
	if not abilityContext.isCopy:
		await CmdMatch.copyAbilityScript(matchState, targetCoinPieceModel.abilityScript, abilityContext.source)
