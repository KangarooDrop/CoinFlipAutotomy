extends MatchState

class_name MatchStateDecision

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

var baseMatchStateRef : WeakRef = null
func getBaseMatchState() -> MatchState:
	return baseMatchStateRef.get_ref()

var _phaseHandler : PhaseHandler = null

#Base information source of the source to call its function in the cloned match state
var testSource : Array = []		#[model source, "function name", [parameters]
#List of targets given since the source was activated
#e.g. [Ability -> Target -> Second Target late in exectution]
#If the depth if less than testTargetQueue.size(), then choose testTargetQueue[depth] as the target. Otherwise, recur
var testTargetQueue : Array[Variant] = []
var targetDepth : int = 0

var iterationDepth : int = 0
var maxIterationDepth : int = 3

var outputTarget : Array[int] = []
var bestDecision : MatchStateDecision = null

var _perspectiveIndex : int = 0
func getPerspectivePlayerModel(perspecive : int = _perspectiveIndex) -> PlayerModel:
	return _playerModelUser if perspecive == 0 else _playerModelOpponent

func _init() -> void:
	_phaseHandler = PhaseHandler.new()
	_phaseHandler.setMatchState(self)
	_phaseHandler.setBinds(
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

func setPhase(matchPhase : PhaseHandler.MATCH_PHASE) -> MatchStateDecision:
	_phaseHandler.currentPhase = matchPhase
	return self

func initTest() -> Array[int]:
	if _phaseHandler.currentPhase == PhaseHandler.MATCH_PHASE.TURN_ACTIONABLE:
		await activateAbilityOfCoinPieceModel(getTarget(Entities.TargetType.COIN_PIECE_FRIENDLY, _activePlayer, _targetFuncCanActivate))
		_phaseHandler.iterPhase()
	else:
		testSource[0].callv(testSource[1], testSource[2])
	return outputTarget

func getHighestEval(targetToEval : Dictionary[Variant, int]) -> Array[Variant]:
	if targetToEval.size() == 0:
		return [null]
	var bestScore : int = -Util.INT_MAX
	var bestTargets : Array = []
	for target : Variant in targetToEval.keys():
		if targetToEval[target] > bestScore:
			bestTargets = [target]
			bestScore = targetToEval[target]
		elif targetToEval[target] == bestScore:
			bestTargets.append(target)
	return bestTargets

func getTarget(targetType : Entities.TargetType, playerModel : PlayerModel, verifyCallable : Callable = _targetFuncTrue) -> Variant:
	if getPerspectivePlayerModel() != playerModel:
		_perspectiveIndex = 1 - _perspectiveIndex
		#print("Swapping perspective at depth=", iterationDepth)
	if not outputTarget.is_empty():
		return null
	elif targetDepth < testTargetQueue.size():
		targetDepth += 1
		return getTargetSerToModel(testTargetQueue[targetDepth-1])
	elif iterationDepth >= maxIterationDepth:
		return null
	else:
		var validTargets : Array[Variant] = getValidTargets(targetType, playerModel, verifyCallable)
		if validTargets.size() == 0:
			return null
		#Append the target to be tested to a copy of testTargetQueue, clone this match state, set test data, and let 'er rip
		var targetToEval : Dictionary[Variant, int] = {}
		var targetToDecision : Dictionary[Variant, MatchStateDecision] = {}
		for newTarget : Variant in validTargets:
			var decision : MatchStateDecision = clone()
			decision.testTargetQueue.append(getModelToTargetSer(newTarget))
			decision.initTest()
			targetToEval[newTarget] = decision.eval(_perspectiveIndex)
			targetToDecision[newTarget] = decision
		var bestTargets : Array[Variant] = getHighestEval(targetToEval)
		#if true:
		if iterationDepth == 0:
			print(iterationDepth)
			print(targetToEval)
		var target : Variant = bestTargets[randi() % bestTargets.size()]
		outputTarget = getModelToTargetSer(target)
		bestDecision = targetToDecision[target]
		return target

func copyFromMatchState(matchState : MatchState) -> void:
	deserialize(matchState.serialize())
	baseMatchStateRef = weakref(matchState)

func clone() -> MatchStateDecision:
	var cloneDecision : MatchStateDecision = MatchStateDecision.new()
	cloneDecision.copyFromMatchState(getBaseMatchState())
	cloneDecision.setPhase(_phaseHandler.currentPhase)
	cloneDecision.testTargetQueue = testTargetQueue.duplicate()
	cloneDecision.iterationDepth = iterationDepth + 1
	cloneDecision._perspectiveIndex = _perspectiveIndex
	return cloneDecision

func eval(_evalPerspective : int) -> int:
	var perspectivePlayerModel : PlayerModel = getPerspectivePlayerModel(_evalPerspective)
	return getSpin(perspectivePlayerModel) - getSpin(getOtherPlayerModel(perspectivePlayerModel))

####################################################################################################

func onResetRound() -> void:
	await super.onResetRound()
	_phaseHandler.iterPhase()

func onMatchStart() -> void:
	await super.onMatchStart()
	_phaseHandler.iterPhase()

func onRoundStart() -> void:
	await super.onRoundStart()
	_phaseHandler.iterPhase()

func onTurnStart() -> void:
	await super.onTurnStart()
	_phaseHandler.iterPhase()

func onTurnActionable() -> void:
	await super.onTurnActionable()
	if outputTarget.is_empty():
		initTest()
	else:
		_phaseHandler.iterPhase()

func onTurnEnd() -> void:
	await super.onTurnEnd()
	_phaseHandler.iterPhase()

func onTurnSkipped() -> void:
	await super.onTurnSkipped()
	_phaseHandler.iterPhase()

func onRoundEnd() -> void:
	await super.onRoundEnd()
	#print("End of Round Decision: ", _spinUser, " ", _spinOpponent)
	#print(_playerModelUser.getCoinFaceModel().getAllSeals(), " ", _playerModelOpponent.getCoinFaceModel().getAllSeals())
	#_phaseHandler.iterPhase()

func onMatchEnd() -> void:
	pass
