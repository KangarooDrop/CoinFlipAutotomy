extends Node
class_name CmdMatch

static func addAdditionalTurn(matchState : MatchState, playerModel : PlayerModel) -> void:
	await matchState.addAdditionalTurn(playerModel)

static func activateAbilityScript(matchState : MatchState, abilityScript : Script, source : RefCounted) -> bool:
	return await matchState.activateAbilityScriptFromSource(abilityScript, source)

static func copyAbilitySameContext(matchState : MatchState, ability : Ability) -> void:
	await matchState.activateAbilityScript(ability.get_script(), ability.abilityContext.clone())

static func copyAbilityScriptNewContext(matchState : MatchState, abilityScript : Script, source : RefCounted) -> bool:
	return await matchState.activateAbilityScriptFromSource(abilityScript, source, true)

#func getMatchState() -> MatchState:
#	var matchNode : MatchNode = getMatchNode()
#	if matchNode == null:
#		return null
#	return matchNode.getMatchState()
