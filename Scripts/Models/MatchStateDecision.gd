extends MatchState

class_name MatchStateDecision

const PERSPECTIVE_INDEX_KEY : String = "perspective_index"
const TARGET_QUEUE_SERIALIZED_KEY : String = "target_queue_serialized"

####################################################################################################

var forceKill : bool = false
func setForceKill(val : bool) -> void:
	forceKill = val
	for child : MatchStateDecision in getAllChildDecisions():
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

var baseData : Dictionary = {}
func setBaseData(data : Dictionary) -> void:
	self.baseData = data.duplicate(true)

#Output vars
var validTargets : Array[RefCounted] = []
var targetToDecisionList : Dictionary[RefCounted, Array] = {}
var hasTargeted : bool = false
var hasChecked : bool = false

var isInActivation : bool = false
var targetingInterupted : bool = false

#var hasInitialized : bool = false
#var hasCheckedDecisions : bool = false

####################################################################################################

func getAllChildDecisions() -> Array[MatchStateDecision]:
	var allDecisions : Array[MatchStateDecision] = []
	for list : Array in targetToDecisionList.values():
		allDecisions.append_array(list)
	return allDecisions

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn[PERSPECTIVE_INDEX_KEY] = _perspectiveIndex
	rtn[TARGET_QUEUE_SERIALIZED_KEY] = targetQueueSerialized.duplicate()
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	super.deserialize(data)
	if data.has(PERSPECTIVE_INDEX_KEY):
		_perspectiveIndex = data[PERSPECTIVE_INDEX_KEY]
	if data.has(TARGET_QUEUE_SERIALIZED_KEY):
		targetQueueSerialized = data[TARGET_QUEUE_SERIALIZED_KEY]
	setBaseData(data)
	return self

func getPerspectivePlayerModel(perspective : int) -> PlayerModel:
	return _playerModelUser if perspective == 0 else _playerModelOpponent

func printEval() -> void:
	print(eval())

func printTree(depth : int = 0) -> void:
	var totalSize : int = getTotalNumDecisions()
	if totalSize > 2000:
		print("ERROR: Decision Tree Too Large == ", totalSize)
		return 
	var spacing : String = "\t".repeat(depth)
	print(spacing, to_string(), ": ", targetToDecisionList.size(), " rng=", baseData[RNG_QUEUE_KEY])
	for target : RefCounted in targetToDecisionList.keys():
		for child : MatchStateDecision in targetToDecisionList[target]:
			child.printTree(depth+1)
		if targetToDecisionList[target].size() == 1:
			print(spacing + "_____________________________")
		else:
			print(spacing + "#############################")
	

####################################################################################################

func _init(data : Dictionary = {}) -> void:
	super._init(data)
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

var targetUsesRNG : bool = false
var rngAccumulationFinished : bool = true
var lastDecision : MatchStateDecision = null
var currentDecision : MatchStateDecision = null
var currentRNGQueue : Array[int] = []
func onStartRNGAccumulator() -> void:
	targetUsesRNG = true
	rngAccumulationFinished = false
func onRNGEnqueued(val : int) -> void:
	currentRNGQueue.append(val)
func onRNGQueueFinished() -> void:
	#print(currentRNGQueue)
	lastDecision.baseData[RNG_QUEUE_KEY].append_array(currentRNGQueue)
	currentRNGQueue = []
func onEndRNGAccumulator() -> void:
	rngAccumulationFinished = true

func iterDecision() -> void:
	if forceKill:
		return
	if not hasChecked:
		hasChecked = true
		for target : RefCounted in validTargets:
			targetToDecisionList[target] = []
			var childTargetQueueSerialized : Array[Array] = targetQueueSerialized.duplicate()
			childTargetQueueSerialized.append(getModelToTargetSerialized(target))
			RNG.start_rng_accumulator.connectSignal(onStartRNGAccumulator)
			RNG.rng_enqueued.connectSignal(onRNGEnqueued)
			RNG.rng_queue_finished.connectSignal(onRNGQueueFinished)
			RNG.end_rng_accumulator.connectSignal(onEndRNGAccumulator)
			RNG.isDeciding = true
			while true:
				lastDecision = currentDecision
				var serializedData : Dictionary = baseData.duplicate(true)
				serializedData[TARGET_QUEUE_SERIALIZED_KEY] = childTargetQueueSerialized
				if childTargetQueueSerialized.size() == 1 and childTargetQueueSerialized[0] == [1, 1, 2]:
					pass
				currentDecision = MatchStateDecision.new(serializedData)
				currentDecision.initDecision()
				if targetUsesRNG and not rngAccumulationFinished:
#					decision.baseData = decision.serialize()
#					decision.targetQueueSerialized = []
					pass
				if not targetUsesRNG or not rngAccumulationFinished:
					targetToDecisionList[target].append(currentDecision)
				if not targetUsesRNG or rngAccumulationFinished:
					break
			RNG.start_rng_accumulator.disconnectSignal(onStartRNGAccumulator)
			RNG.rng_enqueued.disconnectSignal(onRNGEnqueued)
			RNG.rng_queue_finished.disconnectSignal(onRNGQueueFinished)
			RNG.end_rng_accumulator.disconnectSignal(onEndRNGAccumulator)
			RNG.isDeciding = false
			RNG.finishedDeciding = false
			currentDecision = null
			lastDecision = null
		reduce()
	else:
		var hasFinishedIter : bool = true
		for decision : MatchStateDecision in getAllChildDecisions():
			if not decision.hasChecked:
				hasFinishedIter = false
				break
		if not hasFinishedIter:
			for decision : MatchStateDecision in getAllChildDecisions():
				if decision.hasChecked:
					continue
				decision.iterDecision()
		else:
			for decision : MatchStateDecision in getAllChildDecisions():
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
		for target : RefCounted in targetToDecisionList.keys():
			var averageEvalScore : int = evalBranch(target)
			if averageEvalScore > highestScore:
				highestScore = averageEvalScore
		return highestScore

func evalBranch(target : RefCounted) -> int:
	var averageEvalScore : int = 0
	for decision : MatchStateDecision in targetToDecisionList[target]:
		var evalScore : int = decision.eval()
		if decision._perspectiveIndex != _perspectiveIndex and evalScore != -Util.INT_MAX:
			evalScore = -evalScore
		averageEvalScore += evalScore
	if targetToDecisionList[target].size() == 0:
		averageEvalScore = -Util.INT_MAX
	else:
		averageEvalScore /= targetToDecisionList[target].size()
	return averageEvalScore

var _targetToScore : Dictionary[RefCounted, int] = {}
func getEvalDict() -> Dictionary[RefCounted, int]:
	var rtn : Dictionary[RefCounted, int]
	for target : RefCounted in targetToDecisionList.keys():
		for decision : MatchStateDecision in targetToDecisionList[target]:
			decision.getEvalDict()
		var averageEvalScore : int = evalBranch(target)
		rtn[target] = averageEvalScore
	_targetToScore = rtn
	return rtn

func getBestTarget() -> RefCounted:
	if not hasChecked:
		return self
	var evalDict : Dictionary[RefCounted, int] = getEvalDict()
	#print(targetDepth, " ", self, ": ", evalDict)
	var highestScore : int = -Util.INT_MAX
	var highestTarget : RefCounted = null
	for target : RefCounted in evalDict.keys():
		if evalDict[target] > highestScore:
			highestScore = evalDict[target]
			highestTarget = target
	return highestTarget

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
	"""
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
	"""

func getTotalNumDecisions() -> int:
	var total : int = 1
	for decision : MatchStateDecision in getAllChildDecisions():
		total += decision.getTotalNumDecisions()
	return total

####################################################################################################

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

func onTriggerActivated() -> void:
	super.onTriggerActivated()

func onBeforeTriggerCondition() -> void:
	isInActivation = true

func onAfterTriggerCondition() -> void:
	isInActivation = false

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
		isInActivation = true
		await activateAbilityOfCoinPieceModel(getTarget(Entities.TargetType.ABILITY_PIECE_FRIENDLY, _activePlayer, _targetFuncCanActivate))
		isInActivation = false
		if targetQueueSerialized.size() == targetDepth and not targetingInterupted:
			pass
			#baseData = serialize()
			#targetQueueSerialized = []
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
