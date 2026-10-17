extends MatchState

class_name MatchStateDecision

####################################################################################################

var forceKill : bool = false
func setForceKill(val : bool) -> void:
	forceKill = val
	for child : MatchStateDecision in targetToDecision.values():
		child.setForceKill(val)

####################################################################################################

#Input vars
#Base information source of the source to call its function in the cloned match state
var testSource : Array = []		#[model source, "function name", [parameters]
#List of targets given since the source was activated
#e.g. [Ability -> Target -> Second Target late in exectution]
#If the depth if less than testTargetQueue.size(), then choose testTargetQueue[depth] as the target. Otherwise, recur
var targetQueueSerialized : Array[Array] = []
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

var isInActivation : bool = false
var targetingInterupted : bool = false

#var hasInitialized : bool = false
#var hasCheckedDecisions : bool = false

####################################################################################################

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
	if forceKill:
		return
	if not hasChecked:
		hasChecked = true
		for target : RefCounted in validTargets:
			var decision : MatchStateDecision = clone()
			decision.targetQueueSerialized.append(getModelToTargetSerialized(target))
			targetToDecision[target] = decision
			decision.initDecision()
		reduce()
	else:
		var hasFinishedIter : bool = true
		for decision : MatchStateDecision in targetToDecision.values():
			if not decision.hasChecked:
				hasFinishedIter = false
		if not hasFinishedIter:
			for decision : MatchStateDecision in targetToDecision.values():
				if decision.hasChecked:
					continue
				decision.iterDecision()
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

func equals(other : MatchStateDecision) -> bool:
	if (_activePlayer == _playerModelUser) != (other._activePlayer == other._playerModelUser):
		return false
	if getSpinUser() != other.getSpinUser():
		return false
	if getSpinOpponent() != other.getSpinOpponent():
		return false
	if targetingInterupted or other.targetingInterupted:
		return false
	for i in [0, 1]:
		var playerModel : PlayerModel = getPerspectivePlayerModel(i)
		var otherPlayerModel : PlayerModel = other.getPerspectivePlayerModel(i)
		var coinFaceModel : CoinFaceModel = playerModel.getCoinFaceModel()
		var otherCoinFaceModel : CoinFaceModel = otherPlayerModel.getCoinFaceModel()
		if coinFaceModel.getUsedSocketIndices() != otherCoinFaceModel.getUsedSocketIndices():
			return false
		for socketIndex : Entities.CoinPieceSocketIndex in coinFaceModel.getUsedSocketIndices():
			var coinPiece : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(socketIndex)
			var otherCoinPiece : CoinPieceModel = otherCoinFaceModel.getCoinPieceAtSocket(socketIndex)
			if coinPiece.abilityScript != otherCoinPiece.abilityScript:
				return false
			var sealModel : SealModel = coinPiece.getSealModel()
			var otherSealModel : SealModel = otherCoinPiece.getSealModel()
			if ((sealModel==null) != (otherSealModel==null)) or ((sealModel != null and otherSealModel != null) and (sealModel.get_script() != otherSealModel.get_script())):
				return false
		var handModel : HandModel = playerModel.getHandModel()
		var otherHandModel : HandModel = otherPlayerModel.getHandModel()
		for j in range(handModel.getTotalNumFingers()):
			var fingerModel : FingerModel = handModel.getFinger(j)
			var otherFingerModel : FingerModel = otherHandModel.getFinger(j)
			if fingerModel.destroyed != otherFingerModel.destroyed:
				return false
			var ringModel : RingModel = fingerModel.getRingModel()
			var otherRingModel : RingModel = otherFingerModel.getRingModel()
			if (ringModel == null) != (otherRingModel == null):
				return false
			if (ringModel != null and otherRingModel != null) and ringModel.get_script() != otherRingModel.get_script():
				return false
	return true

func reduce() -> void:
	if not hasChecked:
		return
	var index : int = 0
	while index < validTargets.size():
		var target : RefCounted = validTargets[index]
		for j in range(validTargets.size()-1, index, -1):
			var otherTarget : RefCounted = validTargets[j]
			if targetToDecision[target].equals(targetToDecision[otherTarget]):
				targetToDecision.erase(validTargets[j])
				validTargets.remove_at(j)
				pass
				#print("Found reducable target @", self, ": ", index, " == ", j)
				#validTargets.remove_at(j)
		index += 1

func getTotalNumDecisions() -> int:
	var total : int = 1
	for decision : MatchStateDecision in targetToDecision.values():
		total += decision.getTotalNumDecisions()
	return total

####################################################################################################

func activateAbilityScriptFromSource(abilityScript : Script, source : Variant, isCopy : bool = false) -> bool:
	isInActivation = true
	var rtn : bool = await super.activateAbilityScriptFromSource(abilityScript, source, isCopy)
	isInActivation = false
	return rtn
	
func getTarget(targetType : Entities.TargetType, playerModel : PlayerModel, verifyCallable : Callable = _targetFuncTrue) -> Variant:
	if playerModel != getPerspectivePlayerModel(_perspectiveIndex):
		_perspectiveIndex = 1 - _perspectiveIndex
	if targetDepth < targetQueueSerialized.size():
		targetDepth += 1
		return getTargetSerializedToModel(targetQueueSerialized[targetDepth-1])
	elif not hasTargeted:
		hasTargeted = true
		validTargets = getValidTargets(targetType, playerModel, verifyCallable)
		if isInActivation:
			targetingInterupted = true
		return null
	else:
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
		checkTargetingNew()
	phaseHandler.iterPhase()

func onTurnEnd() -> void:
	await super.onTurnEnd()
	phaseHandler.iterPhase()

func onTurnSkipped() -> void:
	await super.onTurnSkipped()
	phaseHandler.iterPhase()

func onRoundEnd() -> void:
	await super.onRoundEnd()

func onMatchEnd() -> void:
	pass




func onBeforeTrigger() -> void:
	checkTargetingNew()

func checkTargetingNew() -> void:
	pass
