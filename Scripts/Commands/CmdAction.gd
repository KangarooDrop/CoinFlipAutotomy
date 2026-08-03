extends Node

func skipTurn() -> void:
	var matchNode : MatchNode = CmdMatch.getMatchNode()
	await matchNode.skipTurn()

func getTarget(matchState : MatchState, targetType : Entities.TargetType, playerModel : PlayerModel) -> Variant:
	return await matchState.getTarget(targetType, playerModel)
