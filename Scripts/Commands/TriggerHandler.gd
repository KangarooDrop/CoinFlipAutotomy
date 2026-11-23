extends Node

#	Conditionals	#
func canActivateAbilityOfCoinPiece(matchState : MatchState, coinPieceModel : CoinPieceModel) -> bool:
	var rtn : bool = true
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		if not (trig.canActivateAbilityOfCoinPiece(matchState, coinPieceModel)):
			rtn = false
			break
	matchState.onAfterTriggerCondition()
	return rtn

#	Match Time Triggers	#
func onMatchStart(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onMatchStart(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onBeforeMatchEnd(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeMatchEnd(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

func onRoundStart(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onRoundStart(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onBeforeRoundEnd(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeRoundEnd(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

func onTurnStart(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onTurnStart(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onBeforeTurnEnd(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeTurnEnd(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

func onBeforeTurnSkipped(matchState : MatchState) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeTurnSkipped(matchState):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

#	Spin Change Triggers	#
func onBeforeSpinChanged(matchState : MatchState, playerModel : PlayerModel, amountPointer : Pointer, source : RefCounted) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeSpinChanged(matchState, playerModel, amountPointer, source):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onAfterSpinChanged(matchState : MatchState, playerModel : PlayerModel, amount : int, source : RefCounted) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onAfterSpinChanged(matchState, playerModel, amount, source):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

#	Ability Triggers	#
func onBeforeAbilityCheck(matchState : MatchState, ability : Ability) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeAbilityCheck(matchState, ability):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onBeforeAbilityActivated(matchState : MatchState, ability : Ability) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeAbilityActivated(matchState, ability):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onAfterAbilityActivated(matchState : MatchState, ability : Ability) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onAfterAbilityActivated(matchState, ability):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onBeforeAbilityCountered(matchState : MatchState, ability : Ability) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeAbilityCountered(matchState, ability):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onAfterAbilityCountered(matchState : MatchState, ability : Ability) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onAfterAbilityCountered(matchState, ability):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

#	Seal Triggers	#
func onBeforeSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, newSealModelPointer : Pointer, source : RefCounted) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeSealChanged(matchState, coinPieceModel, newSealModelPointer, source):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onAfterSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, oldSealModel : SealModel, source : RefCounted) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onAfterSealChanged(matchState, coinPieceModel, oldSealModel, source):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()

#	Finger Ring Triggers	#
func onBeforeFingerDestroyed(matchState : MatchState, fingerModel : FingerModel) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onBeforeFingerDestroyed(matchState, fingerModel):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
func onAfterFingerDestroyed(matchState : MatchState, fingerModel : FingerModel) -> void:
	matchState.onBeforeTriggerCondition()
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		if await trig.onAfterFingerDestroyed(matchState, fingerModel):
			matchState.onTriggerActivated()
	matchState.onAfterTriggerCondition()
