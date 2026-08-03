extends FingerRingModel

class_name RingTwinHeadedOuroboros

var _canActivate : bool = true

####################################################################################################

func getLocID() -> String: return super.getLocID() + "TWIN_HEADED_OUROBOROS"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "twin_headed_ouroboros.png"

####################################################################################################

func onRoundStart(_matchState : MatchState) -> void:
	_canActivate = true

func onBeforeTurnEnd(matchState : MatchState) -> void:
	if not _canActivate:
		return
	if getPlayerModel() == matchState.getActivePlayerModel():
		_canActivate = false

func onAfterAbilityActivated(matchState : MatchState, ability : Ability, _context : AbilityContext) -> void:
	if not _canActivate:
		return
	if getPlayerModel() != matchState.getActivePlayerModel():
		return
	
	popNode()
	_canActivate = false
	var matchNode : MatchNode = CmdMatch.getMatchNode()
	await matchNode.activateAbilityScript(ability.get_script(), self)

func onBeforeAbilityCheck(matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	if matchState.currentTurnNumber <= matchState.NUM_TURNS_MAX - 2:
		return
	if getPlayerModel() != matchState.getActivePlayerModel():
		return
	
	popNode()
	context.isCountered = true
