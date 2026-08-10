extends Node
class_name CmdSpin

static func addSpin(matchState : MatchState, playerModel : PlayerModel, amount : int) -> Pointer:
	return await matchState.addSpin(playerModel, amount)
