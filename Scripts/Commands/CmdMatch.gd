extends Node

func getMatchNode() -> MatchNode:
	for c in get_tree().root.get_children():
		if c is MatchNode:
			return c
	return null

func addAdditionalTurn(matchState : MatchState, playerModel : PlayerModel) -> void:
	matchState.addAdditionalTurn(playerModel)

#func getMatchState() -> MatchState:
#	var matchNode : MatchNode = getMatchNode()
#	if matchNode == null:
#		return null
#	return matchNode.getMatchState()
