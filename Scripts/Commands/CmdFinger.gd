extends Node
class_name CmdFinger

static func getModelToNode(ringModel : RingModel) -> RingNode:
	return null

static func createRingNode(ringModel : RingModel, nodeHolder : Node) -> RingNode:
	var ringNode : RingNode = Preloader.create(Preloader.ringNode)
	nodeHolder.add_child(ringNode)
	ringNode.setModel(ringModel)
	return ringNode

static func freeRingNode(ringNode : RingNode) -> void:
	ringNode.name += "_OLD"
	ringNode.get_parent().remove_child(ringNode)
	#ringNode.setModel(null)
	ringNode.queue_free()

static func createGib(fingerNode : FingerNode) -> FingerGib:
	var fingerGib : FingerGib = Preloader.fingerGibNode.instantiate()
	fingerNode.get_parent().add_child(fingerGib)
	fingerGib.global_position = fingerNode.global_position
	fingerGib.setFromFingerNode(fingerNode)
	return fingerGib

####################################################################################################

static func destroyFinger(matchState : MatchState, fingerModel : FingerModel) -> void:
	await TriggerHandler.onBeforeFingerDestroyed(matchState, fingerModel)
	await fingerModel.destroyFinger()
	await TriggerHandler.onAfterFingerDestroyed(matchState, fingerModel)
	matchState.onFingerDestroyed()
