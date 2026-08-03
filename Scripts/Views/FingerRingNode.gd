extends Node2D

class_name FingerRingNode

@onready var sprite : Sprite2D = $Sprite2D
@onready var tooltipViewer : TooltipViewer = get_node("%TooltipViewer")
@onready var popperNode : PopperNode = get_node("%PopperNode")

var _fingerRingModel : FingerRingModel = null

signal model_changed(newFingerRingModel : FingerRingModel, oldFingerRingModel : FingerRingModel)

####################################################################################################

func _attachModel() -> void:
	_fingerRingModel.pop_node.connectSignal(popNode)

func _unattachModel() -> void:
	_fingerRingModel.pop_node.disconnectSignal(popNode)

####################################################################################################

func setModel(newFingerRingModel : FingerRingModel) -> void:
	if newFingerRingModel == _fingerRingModel:
		return
	if self._fingerRingModel != null:
		_unattachModel()
	var oldFingerRingModel : FingerRingModel = _fingerRingModel
	_fingerRingModel = newFingerRingModel
	sprite.texture = _fingerRingModel.getTextureAtlas()
	_attachModel()
	tooltipViewer.setLocalizedModel(newFingerRingModel)
	model_changed.emit(_fingerRingModel, oldFingerRingModel)

func getModel() -> FingerRingModel:
	return _fingerRingModel

func popNode() -> void:
	await popperNode.popNode()
