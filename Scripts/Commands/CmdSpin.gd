extends Node

func addSpin(matchState : MatchState, playerModel : PlayerModel, amount : int) -> Pointer:
	return await matchState.addSpin(playerModel, amount)
