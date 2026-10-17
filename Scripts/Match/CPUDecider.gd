extends RefCounted

class_name CPUDecider

const MAX_TIME_THRESHOLD : float = 20.0

var cpuTargetThread : Thread = null
var oldTargetThread : Thread = null
var hasForceKilledTargetThread : bool = false
var threadTimer : float = 0.0

var currentDecision : MatchStateDecision = null
var _matchState : MatchState = null

var targetQueueSerialized : Array[Array] = []

var bestTargetQueueSerialized : Array[Array] = []
signal target_serialized_chosen(targetQueueSerialized : Array[int])

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

func initCPUTargetThread() -> Array[int]:
	clearCPUTargetThread()
	threadTimer = 0.0
	hasForceKilledTargetThread = false
	currentDecision = MatchStateDecision.new()
	currentDecision.deserialize(_matchState.serialize())
	currentDecision.setBaseMatchStateRef(_matchState)
	currentDecision._perspectiveIndex = 0 if _matchState.getActivePlayerModel() == _matchState.getPlayerModelUser() else 1
	currentDecision.targetQueueSerialized = targetQueueSerialized
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
	initThread()
	return await target_serialized_chosen

func initThread() -> void:
	if oldTargetThread != null:
		oldTargetThread.wait_to_finish()
	if cpuTargetThread != null:
		oldTargetThread = cpuTargetThread
	
	cpuTargetThread = Thread.new()
	cpuTargetThread.start(iterCPUTargetThread)

func iterCPUTargetThread() -> void:
	var decisionToIter : MatchStateDecision = currentDecision
	decisionToIter.iterDecision()
	if currentDecision != decisionToIter:
		print("Current Decision != Last Decision. Ending Thread.")
		return
	
	if not currentDecision.forceKill:
		printCurrentDecision()
		bestTargetQueueSerialized = currentDecision.getBestDecision().targetQueueSerialized
	else:
		print("Current Decision Force Killed.")
	
	if isTimeExceeded():
		print("Current time exceeded. Ending Thread.")
		call_deferred("emitBestTargetQueueSerialized")
		return
	
	initThread()

func emitBestTargetQueueSerialized() -> void:
	target_serialized_chosen.emit(bestTargetQueueSerialized[targetQueueSerialized.size()])

func printCurrentDecision() -> void:
	print("Total Decisions: ", currentDecision.getTotalNumDecisions())
	print(currentDecision.getEvalDict())
	var bestDecision : MatchStateDecision = currentDecision.getBestDecision()
	print(bestDecision.targetQueueSerialized)
	print()

func clearCPUTargetThread() -> void:
	if cpuTargetThread != null and cpuTargetThread.is_alive():
		cpuTargetThread.wait_to_finish()
	if oldTargetThread != null and oldTargetThread.is_alive():
		oldTargetThread.wait_to_finish()

func _process(delta : float):
	threadTimer += delta
	if isTimeExceeded() and currentDecision != null and not hasForceKilledTargetThread:
		forceKill()

func forceKill() -> void:
	hasForceKilledTargetThread = true
	currentDecision.setForceKill(true)

func isTimeExceeded() -> bool:
	return threadTimer >= MAX_TIME_THRESHOLD
