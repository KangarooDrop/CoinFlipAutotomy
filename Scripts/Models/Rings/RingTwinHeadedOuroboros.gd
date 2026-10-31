extends RingModel

class_name RingTwinHeadedOuroboros

var _canActivate : bool = true

####################################################################################################

func getLocID() -> String: return super.getLocID() + "TWIN_HEADED_OUROBOROS"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "twin_headed_ouroboros.png"

####################################################################################################

func onRoundStart(_matchState : MatchState) -> bool:
	_canActivate = true
	return true

func onBeforeTurnEnd(matchState : MatchState) -> bool:
	if not _canActivate:
		return false
	if getPlayerModel() != matchState.getActivePlayerModel():
		return false
	_canActivate = false
	return true

func onAfterAbilityActivated(matchState : MatchState, ability : Ability, _context : AbilityContext) -> bool:
	if not _canActivate:
		return false
	if getPlayerModel() != matchState.getActivePlayerModel():
		return false
	
	popNode()
	_canActivate = false
	await CmdMatch.copyAbilityScript(matchState, ability.get_script(), self)
	return true

func onBeforeAbilityCheck(matchState : MatchState, _ability : Ability, context : AbilityContext) -> bool:
	if matchState.currentTurnNumber <= matchState.NUM_TURNS_MAX - 2:
		return false
	if getPlayerModel() != matchState.getActivePlayerModel():
		return false
	
	popNode()
	context.isCountered = true
	return true
