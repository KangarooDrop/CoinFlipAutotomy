extends Node

func skipTurn() -> void:
	var matchNode : MatchNode = CmdMatch.getMatchNode()
	await matchNode.skipTurn()

func getAbilityTarget(abilityTargetType : Entities.AbilityTargetType, playerModel : PlayerModel) -> Variant:
	var matchNode : MatchNode = CmdMatch.getMatchNode()
	return await matchNode.getAbilityTarget(abilityTargetType, playerModel)
	
