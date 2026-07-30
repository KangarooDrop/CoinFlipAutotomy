extends Node2D

class_name FingerRingNode

@onready var sprite : Sprite2D = $Sprite2D
@onready var tooltipViewer : TooltipViewer = get_node("%TooltipViewer")

var _fingerRingModel : FingerRingModel = null

signal model_changed(newFingerRingModel : FingerRingModel, oldFingerRingModel : FingerRingModel)

####################################################################################################

func _attachModel(fingerRing : FingerRingModel) -> void:
	pass

func _unattachModel(fingerRing : FingerRingModel) -> void:
	pass

####################################################################################################

func setModel(newFingerRingModel : FingerRingModel) -> void:
	if newFingerRingModel == _fingerRingModel:
		return
	if self._fingerRingModel != null:
		_unattachModel(_fingerRingModel)
	var oldFingerRingModel : FingerRingModel = _fingerRingModel
	_fingerRingModel = newFingerRingModel
	sprite.texture = _fingerRingModel.getTextureAtlas()
	_attachModel(_fingerRingModel)
	tooltipViewer.setLocalizedModel(newFingerRingModel)
	model_changed.emit(_fingerRingModel, oldFingerRingModel)

func getModel() -> FingerRingModel:
	return _fingerRingModel
