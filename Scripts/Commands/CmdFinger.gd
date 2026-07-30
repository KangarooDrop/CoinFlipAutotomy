extends Node

var _modelToNode : Dictionary[FingerRingModel, FingerRingNode] = {}

####################################################################################################

func _onFingerRingModelChange(newFingerRingModel : FingerRingModel, oldFingerRingModel : FingerRingModel, fingerRingNode : FingerRingNode) -> void:
	_modelToNode.erase(oldFingerRingModel)
	_modelToNode[newFingerRingModel] = fingerRingNode

####################################################################################################

func getModelToNode(fingerRingModel : FingerRingModel) -> FingerRingNode:
	if not _modelToNode.has(fingerRingModel):
		return null
	return _modelToNode[fingerRingModel]

func createFingerRingNode(fingerRingModel : FingerRingModel, nodeHolder : Node) -> FingerRingNode:
	var fingerRingNode : FingerRingNode = Preloader.create(Preloader.fingerRingNode)
	nodeHolder.add_child(fingerRingNode)
	fingerRingNode.setModel(fingerRingModel)
	_modelToNode[fingerRingModel] = fingerRingNode
	fingerRingNode.model_changed.connect(_onFingerRingModelChange.bind(fingerRingNode))
	return fingerRingNode

func freeFingerRingNode(fingerRingNode : FingerRingNode) -> void:
	var model : FingerRingModel = fingerRingNode.getModel()
	if _modelToNode.has(model):
		_modelToNode.erase(model)
	fingerRingNode.name += "_OLD"
	fingerRingNode.get_parent().remove_child(fingerRingNode)
	#fingerRingNode.setModel(null)
	fingerRingNode.queue_free()

func destroyFinger(fingerModel : FingerModel) -> void:
	var matchState : MatchState = CmdMatch.getMatchState()
	if matchState == null:
		return
	
	await TriggerHandler.onBeforeFingerDestroyed(matchState, fingerModel)
	fingerModel.destroyFinger()
	await TriggerHandler.onAfterFingerDestroyed(matchState, fingerModel)
	matchState.onFingerDestroyed()

func createGib(fingerNode : FingerNode) -> FingerGib:
	var fingerGib : FingerGib = Preloader.fingerGibNode.instantiate()
	add_child(fingerGib)
	fingerGib.global_position = fingerNode.global_position
	fingerGib.setFromFingerNode(fingerNode)
	return fingerGib
