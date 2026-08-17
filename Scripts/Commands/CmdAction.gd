extends Node
class_name CmdAction

static func skipTurn(matchState : MatchState) -> void:
	if matchState._ma:
		pass
	#var matchNode : MatchNode = CmdMatch.getMatchNode()
	#await matchNode.skipTurn()

static func getTarget(matchState : MatchState, targetType : Entities.TargetType, playerModel : PlayerModel) -> Variant:
	return await matchState.getTarget(targetType, playerModel)

static func getCoinPieceToActivate(matchState : MatchState, playerModel : PlayerModel) -> CoinPieceModel:
	return await matchState.getTargetCoinPieceCanActivate(playerModel)
