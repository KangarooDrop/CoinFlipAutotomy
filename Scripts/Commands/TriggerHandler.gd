extends Node

#	Match Time Triggers	#
func onMatchStart(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onMatchStart(matchState)
func onBeforeMatchEnd(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeMatchEnd(matchState)

func onRoundStart(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onRoundStart(matchState)
func onBeforeRoundEnd(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeRoundEnd(matchState)

func onTurnStart(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onTurnStart(matchState)
func onBeforeTurnEnd(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeTurnEnd(matchState)

func onBeforeTurnSkipped(matchState : MatchState) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeTurnSkipped(matchState)

#	Spin Change Triggers	#
func onBeforeSpinChanged(matchState : MatchState, playerModel : PlayerModel, amountPointer : Pointer) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeSpinChanged(matchState, playerModel, amountPointer)
func onAfterSpinChanged(matchState : MatchState, playerModel : PlayerModel) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onAfterSpinChanged(matchState, playerModel)

#	Ability Triggers	#
func onBeforeAbilityCheck(matchState : MatchState, ability : Ability, context : AbilityContext) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeAbilityCheck(matchState, ability, context)
func onBeforeAbilityActivated(matchState : MatchState, ability : Ability, context : AbilityContext) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeAbilityActivated(matchState, ability, context)
func onAfterAbilityActivated(matchState : MatchState, ability : Ability, context : AbilityContext) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onAfterAbilityActivated(matchState, ability, context)
func onBeforeAbilityCountered(matchState : MatchState, ability : Ability, context : AbilityContext) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeAbilityCountered(matchState, ability, context)
func onAfterAbilityCountered(matchState : MatchState, ability : Ability, context : AbilityContext) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onAfterAbilityCountered(matchState, ability, context)

#	Seal Triggers	#
func onBeforeSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, newSealModelPointer : Pointer) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeSealChanged(matchState, coinPieceModel, newSealModelPointer)
func onAfterSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, oldSealModel : SealModel) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onAfterSealChanged(matchState, coinPieceModel, oldSealModel)

#	Finger Ring Triggers	#
func onBeforeFingerDestroyed(matchState : MatchState, fingerModel : FingerModel) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onBeforeFingerDestroyed(matchState, fingerModel)
func onAfterFingerDestroyed(matchState : MatchState, fingerModel : FingerModel) -> void:
	for trig : Triggerable in matchState.getAllTriggerables():
		@warning_ignore("redundant_await")
		await trig.onAfterFingerDestroyed(matchState, fingerModel)
