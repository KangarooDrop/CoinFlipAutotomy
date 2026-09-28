extends RefCounted

class_name PhaseHandler

enum MATCH_PHASE {
	NONE,
	RESET,
	MATCH_START,
	ROUND_START,
	TURN_START,
	TURN_ACTIONABLE,
	TURN_END,
	ROUND_END,
	MATCH_END,
}

var binds : Dictionary[MATCH_PHASE, Callable] = {}
func setBinds(newBinds : Dictionary[MATCH_PHASE, Callable]) -> void:
	if not newBinds.size() == MATCH_PHASE.size()-1:
		push_warning("WARNING: Phase Handler binds size != number of phases.")
	binds = newBinds

func callBound() -> void:
	if not binds.has(currentPhase):
		return
	binds[currentPhase].call()
func callBoundDeferred() -> void:
	if not binds.has(currentPhase):
		return
	binds[currentPhase].call_deferred()

var _matchStateRef : WeakRef = null
func setMatchState(matchState : MatchState) -> void:
	_matchStateRef = weakref(matchState)
func getMatchState() -> MatchState:
	if _matchStateRef == null:
		return null
	return _matchStateRef.get_ref()

var currentPhase : MATCH_PHASE = MATCH_PHASE.NONE

func _iterPhaseInternal() -> void:
	match currentPhase:
		MATCH_PHASE.NONE:
			currentPhase = MATCH_PHASE.MATCH_START
		MATCH_PHASE.MATCH_START:
			currentPhase = MATCH_PHASE.RESET
		MATCH_PHASE.RESET:
			currentPhase = MATCH_PHASE.ROUND_START
		MATCH_PHASE.ROUND_START:
			currentPhase = MATCH_PHASE.TURN_START
		MATCH_PHASE.TURN_START:
			currentPhase = MATCH_PHASE.TURN_ACTIONABLE
		MATCH_PHASE.TURN_ACTIONABLE:
			currentPhase = MATCH_PHASE.TURN_END
		MATCH_PHASE.TURN_END:
			var matchState : MatchState = getMatchState()
			if matchState.currentTurnsRemaining > 0:
				currentPhase = MATCH_PHASE.TURN_START
			else:
				currentPhase = MATCH_PHASE.ROUND_END
		MATCH_PHASE.ROUND_END:
			var matchState : MatchState = getMatchState()
			if matchState.winningPlayers.size() == 0:
				currentPhase = MATCH_PHASE.RESET
			else:
				currentPhase = MATCH_PHASE.MATCH_END
		_:
			return
	#print("Setting phasers to ", MATCH_PHASE.keys()[currentPhase].capitalize())

func iterPhase() -> void:
	_iterPhaseInternal()
	callBound()

func iterPhaseDeferred() -> void:
	_iterPhaseInternal()
	callBoundDeferred()
