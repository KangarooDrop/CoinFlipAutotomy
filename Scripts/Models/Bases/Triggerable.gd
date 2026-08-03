@abstract
extends LocalizedModel

class_name Triggerable

var pop_node : CFSignal = CFSignal.new(CFSignal.WAIT_TYPE_PARALLEL)

func popNode() -> void:
	await pop_node.emitSignal()

####################################################################################################
#	Match Time Triggers	#
func onMatchStart(_matchState : MatchState) -> void:
	pass
func onBeforeMatchEnd(_matchState : MatchState) -> void:
	pass

func onRoundStart(_matchState : MatchState) -> void:
	pass
func onBeforeRoundEnd(_matchState : MatchState) -> void:
	pass

func onTurnStart(_matchState : MatchState) -> void:
	pass
func onBeforeTurnEnd(_matchState : MatchState) -> void:
	pass

func onBeforeTurnSkipped(_matchState : MatchState) -> void:
	pass

#	Spin Change Triggers	#
func onBeforeSpinChanged(_matchState : MatchState, _playerModel : PlayerModel, _amountPointer : Pointer) -> void:
	pass
func onAfterSpinChanged(_matchState : MatchState, _playerModel : PlayerModel) -> void:
	pass

#	Ability Triggers	#
func onBeforeAbilityCheck(_matchState : MatchState, _ability : Ability, _context : AbilityContext) -> void:
	pass
func onBeforeAbilityActivated(_matchState : MatchState, _ability : Ability, _context : AbilityContext) -> void:
	pass
func onAfterAbilityActivated(_matchState : MatchState, _ability : Ability, _context : AbilityContext) -> void:
	pass
func onBeforeAbilityCountered(_matchState : MatchState, _ability : Ability, _context : AbilityContext) -> void:
	pass
func onAfterAbilityCountered(_matchState : MatchState, _ability : Ability, _context : AbilityContext) -> void:
	pass

#	Seal Triggers	#
func onBeforeSealChanged(_matchState : MatchState, _coinPieceModel : CoinPieceModel, _newSealModelPointer : Pointer) -> void:
	pass
func onAfterSealChanged(_matchState : MatchState, _coinPieceModel : CoinPieceModel, _oldSealModel : SealModel) -> void:
	pass

#	Finger Ring Triggers	#
func onBeforeFingerDestroyed(_matchState : MatchState, _fingerRingModel : FingerModel) -> void:
	pass
func onAfterFingerDestroyed(_matchState : MatchState, _fingerRingModel : FingerModel) -> void:
	pass
