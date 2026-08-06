extends Node2D

class_name RingNode

@onready var sprite : Sprite2D = $Sprite2D
@onready var tooltipViewer : TooltipViewer = get_node("%TooltipViewer")
@onready var popperNode : PopperNode = get_node("%PopperNode")

var _ringModel : RingModel = null

signal model_changed(newRingModel : RingModel, oldRingModel : RingModel)

####################################################################################################

func _attachModel() -> void:
	_ringModel.pop_node.connectSignal(popNode)

func _unattachModel() -> void:
	_ringModel.pop_node.disconnectSignal(popNode)

####################################################################################################

func setModel(newRingModel : RingModel) -> void:
	if newRingModel == _ringModel:
		return
	if self._ringModel != null:
		_unattachModel()
	var oldRingModel : RingModel = _ringModel
	_ringModel = newRingModel
	sprite.texture = _ringModel.getTextureAtlas()
	_attachModel()
	tooltipViewer.setLocalizedModel(newRingModel)
	model_changed.emit(_ringModel, oldRingModel)

func getModel() -> RingModel:
	return _ringModel

func popNode() -> void:
	await popperNode.popNode()
