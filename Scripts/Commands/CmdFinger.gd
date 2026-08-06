extends Node

var _modelToNode : Dictionary[RingModel, RingNode] = {}

####################################################################################################

func _onRingModelChange(newRingModel : RingModel, oldRingModel : RingModel, ringNode : RingNode) -> void:
	_modelToNode.erase(oldRingModel)
	_modelToNode[newRingModel] = ringNode

####################################################################################################

func getModelToNode(ringModel : RingModel) -> RingNode:
	if not _modelToNode.has(ringModel):
		return null
	return _modelToNode[ringModel]

func createRingNode(ringModel : RingModel, nodeHolder : Node) -> RingNode:
	var ringNode : RingNode = Preloader.create(Preloader.ringNode)
	nodeHolder.add_child(ringNode)
	ringNode.setModel(ringModel)
	_modelToNode[ringModel] = ringNode
	ringNode.model_changed.connect(_onRingModelChange.bind(ringNode))
	return ringNode

func freeRingNode(ringNode : RingNode) -> void:
	var model : RingModel = ringNode.getModel()
	if _modelToNode.has(model):
		_modelToNode.erase(model)
	ringNode.name += "_OLD"
	ringNode.get_parent().remove_child(ringNode)
	#ringNode.setModel(null)
	ringNode.queue_free()

func createGib(fingerNode : FingerNode) -> FingerGib:
	var fingerGib : FingerGib = Preloader.fingerGibNode.instantiate()
	add_child(fingerGib)
	fingerGib.global_position = fingerNode.global_position
	fingerGib.setFromFingerNode(fingerNode)
	return fingerGib

####################################################################################################

func destroyFinger(matchState : MatchState, fingerModel : FingerModel) -> void:
	await TriggerHandler.onBeforeFingerDestroyed(matchState, fingerModel)
	await fingerModel.destroyFinger()
	await TriggerHandler.onAfterFingerDestroyed(matchState, fingerModel)
	matchState.onFingerDestroyed()
