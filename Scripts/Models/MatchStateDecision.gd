extends MatchState

class_name MatchStateDecision

#Input vars
#Base information source of the source to call its function in the cloned match state
var testSource : Array = []		#[model source, "function name", [parameters]
#List of targets given since the source was activated
#e.g. [Ability -> Target -> Second Target late in exectution]
#If the depth if less than testTargetQueue.size(), then choose testTargetQueue[depth] as the target. Otherwise, recur
var targetQueueSerialized : Array[Variant] = []
var targetDepth : int = 0
var _perspectiveIndex : int = 0

####################################################################################################

var baseMatchStateRef : WeakRef = null
func setBaseMatchStateRef(matchState : MatchState) -> void:
	baseMatchStateRef = weakref(matchState)
func getBaseMatchState() -> MatchState:
	return baseMatchStateRef.get_ref()

#Output vars
var validTargets : Array[RefCounted] = []
var targetToDecision : Dictionary[RefCounted, MatchStateDecision] = {}
var hasTargeted : bool = false
var hasChecked : bool = false
#var hasInitialized : bool = false
#var hasCheckedDecisions : bool = false

####################################################################################################

const FINGER_TARGET : int = 0
const COIN_PIECE_TARGET : int = 1
func getModelToTargetSer(model : RefCounted) -> Array[int]:
	var playerModels : Array[PlayerModel] = [_playerModelUser, _playerModelOpponent]
	for i in range(playerModels.size()):
		var fingerModels : Array[FingerModel] = playerModels[i].getHandModel().getFingers()
		for j in range(fingerModels.size()):
			if model == fingerModels[j] or model == fingerModels[j].getRingModel():
				return [i, FINGER_TARGET, j]
		var coinPieceModels : Array[CoinPieceModel] = playerModels[i].getCoinFaceModel().getAllPieces()
		for j in range(coinPieceModels.size()):
			if model == coinPieceModels[j] or model == coinPieceModels[j].getSealModel():
				return [i, COIN_PIECE_TARGET, j]
	return []
func getTargetSerToModel(data : Array[int]) -> RefCounted:
	var playerModel : PlayerModel = _playerModelUser if data[0]==0 else _playerModelOpponent
	if data[1] == FINGER_TARGET:
		return playerModel.getHandModel().getFinger(data[2])
	elif data[1] == COIN_PIECE_TARGET:
		return playerModel.getCoinFaceModel().getAllPieces()[data[2]]
	return null
func getTargetSerToReadable(data : Array[int]) -> String:
	var rtn : String = ""
	var isUser : bool = data[0] == 0
	var isCoinPiece : bool = data[1] == COIN_PIECE_TARGET
	rtn += "Best Target: "
	rtn += "Your " if isUser else "Opponent's "
	rtn += "Coin Piece Socket#" if isCoinPiece else "Finger #"
	rtn += str(data[2])
	return rtn

func clone() -> MatchStateDecision:
	var cloneDecision : MatchStateDecision = MatchStateDecision.new()
	cloneDecision.deserialize(getBaseMatchState().serialize())
	cloneDecision.baseMatchStateRef = baseMatchStateRef
	cloneDecision.targetQueueSerialized = targetQueueSerialized.duplicate()
	cloneDecision._perspectiveIndex = _perspectiveIndex
	return cloneDecision

func getPerspectivePlayerModel(perspective : int) -> PlayerModel:
	return _playerModelUser if perspective == 0 else _playerModelOpponent

func printEval() -> void:
	print(eval())

####################################################################################################

func _init() -> void:
	super._init()
	phaseHandler.setBinds(
		{
			PhaseHandler.MATCH_PHASE.RESET : 			onResetRound,
			PhaseHandler.MATCH_PHASE.MATCH_START : 		onMatchStart,
			PhaseHandler.MATCH_PHASE.ROUND_START : 		onRoundStart,
			PhaseHandler.MATCH_PHASE.TURN_START : 		onTurnStart,
			PhaseHandler.MATCH_PHASE.TURN_ACTIONABLE : 	onTurnActionable,
			PhaseHandler.MATCH_PHASE.TURN_END : 		onTurnEnd,
			PhaseHandler.MATCH_PHASE.ROUND_END : 		onRoundEnd,
			PhaseHandler.MATCH_PHASE.MATCH_END : 		onMatchEnd,
		})

func initDecision() -> void:
	phaseHandler.callBound()

func iterDecision() -> void:
	if not hasChecked:
		hasChecked = true
		for target : RefCounted in validTargets:
			var decision : MatchStateDecision = clone()
			decision.targetQueueSerialized.append(getModelToTargetSer(target))
			targetToDecision[target] = decision
			decision.initDecision()
	else:
		for decision : MatchStateDecision in targetToDecision.values():
			decision.iterDecision()

func eval() -> int:
	#No valid targets (e.g. ability targets seal but there are none)
	if hasTargeted and validTargets.size() == 0:
		return -Util.INT_MAX
	#hasTargeted and not hasChecked -> the decision is a leaf
	#not hasTargeted and hasChecked -> end of round
	elif not hasTargeted or not hasChecked:
		var perspectivePlayerModel : PlayerModel = getPerspectivePlayerModel(_perspectiveIndex)
		return getSpin(perspectivePlayerModel) - getSpin(getOtherPlayerModel(perspectivePlayerModel))
	#Otherwise, check child decisions
	else:
		var highestScore : int = -Util.INT_MAX
		for target : RefCounted in targetToDecision.keys():
			var evalScore : int = targetToDecision[target].eval()
			if targetToDecision[target]._perspectiveIndex != _perspectiveIndex and evalScore != -Util.INT_MAX:
				evalScore = -evalScore
			if evalScore > highestScore:
				highestScore = evalScore
		return highestScore

func getEvalDict() -> Dictionary[MatchStateDecision, int]:
	var rtn : Dictionary[MatchStateDecision, int]
	for target : RefCounted in targetToDecision.keys():
		var evalScore : int = targetToDecision[target].eval()
		if targetToDecision[target]._perspectiveIndex != _perspectiveIndex and evalScore != -Util.INT_MAX:
			evalScore = -evalScore
		rtn[targetToDecision[target]] = evalScore
	return rtn

var _decisionToScore : Dictionary[MatchStateDecision, int] = {}
func getBestDecision() -> MatchStateDecision:
	if not hasChecked:
		return self
	var evalDict : Dictionary = getEvalDict()
	#print(targetDepth, " ", self, ": ", evalDict)
	_decisionToScore = evalDict
	var highestScore : int = -Util.INT_MAX
	var highestDecision : MatchStateDecision = self
	for decision : MatchStateDecision in evalDict.keys():
		decision.getBestDecision()
		if evalDict[decision] > highestScore:
			highestScore = evalDict[decision]
			highestDecision = decision.getBestDecision()
	return highestDecision

####################################################################################################

func getTarget(targetType : Entities.TargetType, playerModel : PlayerModel, verifyCallable : Callable = _targetFuncTrue) -> Variant:
	if playerModel != getPerspectivePlayerModel(_perspectiveIndex):
		_perspectiveIndex = 1 - _perspectiveIndex
	if targetDepth < targetQueueSerialized.size():
		targetDepth += 1
		return getTargetSerToModel(targetQueueSerialized[targetDepth-1])
	else:
		hasTargeted = true
		validTargets = getValidTargets(targetType, playerModel, verifyCallable)
		#setBaseMatchStateRef(self)
		return null

####################################################################################################

func onResetRound() -> void:
	await super.onResetRound()
	phaseHandler.iterPhase()

func onMatchStart() -> void:
	await super.onMatchStart()
	phaseHandler.iterPhase()

func onRoundStart() -> void:
	await super.onRoundStart()
	phaseHandler.iterPhase()

func onTurnStart() -> void:
	await super.onTurnStart()
	phaseHandler.iterPhase()

func onTurnActionable() -> void:
	await super.onTurnActionable()
	if not hasTargeted:
		await activateAbilityOfCoinPieceModel(getTarget(Entities.TargetType.ABILITY_PIECE_FRIENDLY, _activePlayer, _targetFuncCanActivate))
	phaseHandler.iterPhase()

func onTurnEnd() -> void:
	await super.onTurnEnd()
	phaseHandler.iterPhase()

func onTurnSkipped() -> void:
	await super.onTurnSkipped()
	phaseHandler.iterPhase()

func onRoundEnd() -> void:
	await super.onRoundEnd()
	#print("End of Round Decision: ", _spinUser, " ", _spinOpponent)
	#print(_playerModelUser.getCoinFaceModel().getAllSeals(), " ", _playerModelOpponent.getCoinFaceModel().getAllSeals())
	#phaseHandler.iterPhase()

func onMatchEnd() -> void:
	pass
