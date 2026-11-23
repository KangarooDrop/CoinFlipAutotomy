@abstract
extends LocalizedModel

class_name Triggerable

var pop_node : CFSignal = CFSignal.new(CFSignal.WAIT_TYPE_PARALLEL)

func popNode() -> void:
	await pop_node.emitSignal()

####################################################################################################
#	Conditionals	#
func canActivateAbilityOfCoinPiece(_matchState : MatchState, _coinPieceModel : CoinPieceModel) -> bool:
	return true

#	Match Time Triggers	#
func onMatchStart(_matchState : MatchState) -> bool:
	return false
func onBeforeMatchEnd(_matchState : MatchState) -> bool:
	return false

func onRoundStart(_matchState : MatchState) -> bool:
	return false
func onBeforeRoundEnd(_matchState : MatchState) -> bool:
	return false

func onTurnStart(_matchState : MatchState) -> bool:
	return false
func onBeforeTurnEnd(_matchState : MatchState) -> bool:
	return false

func onBeforeTurnSkipped(_matchState : MatchState) -> bool:
	return false

#	Spin Change Triggers	#
func onBeforeSpinChanged(_matchState : MatchState, _playerModel : PlayerModel, _amountPointer : Pointer, _source : RefCounted) -> bool:
	return false
func onAfterSpinChanged(_matchState : MatchState, _playerModel : PlayerModel, _amount : int, _source : RefCounted) -> bool:
	return false

#	Ability Triggers	#
func onBeforeAbilityCheck(_matchState : MatchState, _ability : Ability) -> bool:
	return false
func onBeforeAbilityActivated(_matchState : MatchState, _ability : Ability) -> bool:
	return false
func onAfterAbilityActivated(_matchState : MatchState, _ability : Ability) -> bool:
	return false
func onBeforeAbilityCountered(_matchState : MatchState, _ability : Ability) -> bool:
	return false
func onAfterAbilityCountered(_matchState : MatchState, _ability : Ability) -> bool:
	return false

#	Seal Triggers	#
func onBeforeSealChanged(_matchState : MatchState, _coinPieceModel : CoinPieceModel, _newSealModelPointer : Pointer, _source : RefCounted) -> bool:
	return false
func onAfterSealChanged(_matchState : MatchState, _coinPieceModel : CoinPieceModel, _oldSealModel : SealModel, _source : RefCounted) -> bool:
	return false

#	Finger Ring Triggers	#
func onBeforeFingerDestroyed(_matchState : MatchState, _fingerModel : FingerModel) -> bool:
	return false
func onAfterFingerDestroyed(_matchState : MatchState, _fingerodel : FingerModel) -> bool:
	return false
