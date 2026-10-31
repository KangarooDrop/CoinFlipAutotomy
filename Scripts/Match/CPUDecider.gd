extends RefCounted

class_name CPUDecider

const USE_THREADS : bool = true
const MAX_MS_THRESHOLD : int = 10_000

var cpuTargetThread : Thread = null
var oldTargetThread : Thread = null
var hasForceKilledTargetThread : bool = false
var msStarted : int = 0

var currentDecision : MatchStateDecision = null
var _matchState : MatchState = null

var targetQueueSerialized : Array[Array] = []

var bestTargetSerialized : Array[int] = []
signal target_serialized_chosen(targetSerialized : Array[int])

func setMatchState(matchState : MatchState) -> void:
	self._matchState = matchState

"""
func traverseDecisionTree(serializedTarget : Array[int]) -> bool:
	if currentDecision == null:
		return false
	var target : RefCounted = currentDecision.getTargetSerializedToModel(serializedTarget)
	if currentDecision.targetToDecision.has(target):
		currentDecision = currentDecision.targetToDecision[target]
		queueIndex += 1
		return true
	currentDecision = null
	return false
"""

func initCPUTarget() -> Array[int]:
	if USE_THREADS:
		clearCPUTargetThread()
	msStarted = Time.get_ticks_msec()
	hasForceKilledTargetThread = false
	var serializedData : Dictionary = _matchState.serialize()
	serializedData[MatchStateDecision.PERSPECTIVE_INDEX_KEY] = 0 if _matchState.getActivePlayerModel() == _matchState.getPlayerModelUser() else 1
	serializedData[MatchStateDecision.TARGET_QUEUE_SERIALIZED_KEY] = targetQueueSerialized
	currentDecision = MatchStateDecision.new(serializedData)
	currentDecision.initDecision()
	"""
	if currentDecision == null:
		currentDecision = MatchStateDecision.new()
		currentDecision.deserialize(_matchState.serialize())
		currentDecision.setBaseMatchStateRef(_matchState)
		currentDecision._perspectiveIndex = 0 if _matchState.getActivePlayerModel() == _matchState.getPlayerModelUser() else 1
		currentDecision.initDecision()
	else:
		currentDecision.setForceKill(false)
	"""
	_initCPUTargetInternal()
	return await target_serialized_chosen

func _initCPUTargetInternal() -> void:
	if USE_THREADS:
		if oldTargetThread != null:
			oldTargetThread.wait_to_finish()
		if cpuTargetThread != null:
			oldTargetThread = cpuTargetThread
		
		cpuTargetThread = Thread.new()
		cpuTargetThread.start(_iterCPUTarget)
	else:
		_iterCPUTarget()

func _iterCPUTarget() -> void:
	var decisionToIter : MatchStateDecision = currentDecision
	decisionToIter.iterDecision()
	if currentDecision != decisionToIter:
		print("Current Decision != Last Decision. Ending Thread.")
		return
	
	if not currentDecision.forceKill:
		printCurrentDecision()
		bestTargetSerialized = currentDecision.getModelToTargetSerialized(currentDecision.getBestTarget())
	else:
		print("Current Decision Force Killed.")
	
	if isTimeExceeded():
		print("Current time exceeded. Ending.")
		call_deferred("emitBestTargetSerialized")
		return
	
	_initCPUTargetInternal()

func emitBestTargetSerialized() -> void:
	target_serialized_chosen.emit(bestTargetSerialized)

func printCurrentDecision() -> void:
	var totalDecisions : int = currentDecision.getTotalNumDecisions()
	print("Total Decisions: ", totalDecisions)
	#if totalDecisions == 127:
	#	currentDecision.printTree()
	if totalDecisions > 500:
		pass
		#currentDecision.printTree()
	print("Elapsed Time: ", Time.get_ticks_msec() - msStarted, " ms.")
	print(currentDecision.getEvalDict())
	print(currentDecision.getModelToTargetSerialized(currentDecision.getBestTarget()))
	print()

func clearCPUTargetThread() -> void:
	if cpuTargetThread != null and cpuTargetThread.is_alive():
		cpuTargetThread.wait_to_finish()
	if oldTargetThread != null and oldTargetThread.is_alive():
		oldTargetThread.wait_to_finish()

func _process(_delta : float):
	if isTimeExceeded() and currentDecision != null and not hasForceKilledTargetThread:
		forceKill()

func forceKill() -> void:
	hasForceKilledTargetThread = true
	if currentDecision != null:
		currentDecision.setForceKill(true)

func isTimeExceeded() -> bool:
	return msStarted + MAX_MS_THRESHOLD < Time.get_ticks_msec()
		 
