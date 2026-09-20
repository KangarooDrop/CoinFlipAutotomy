extends Ability
class_name AbilityJoinMe

const SPIN_DEC : int = 40

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "JOIN_ME"

func getTexturePath() -> String:
	return super.getTexturePath() + "join_me.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

####################################################################################################

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_DEC

func canActivateAbilityOfCoinPiece(matchState : MatchState, coinPieceModel : CoinPieceModel) -> bool:
	return matchState.getSpin(coinPieceModel.getPlayerModel()) < 0

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 0:
		push_error("ERROR: Invalid num targets given to AbilityJoinMe.activate: " + str(abilityContext.targets.size()) + " != 0.")
		return
	
	var playerModel : PlayerModel = getPlayerModel(abilityContext)
	var opponentPlayerModel : PlayerModel = matchState.getOtherPlayerModel(playerModel)
	await CmdSpin.addSpin(matchState, opponentPlayerModel, -SPIN_DEC)
