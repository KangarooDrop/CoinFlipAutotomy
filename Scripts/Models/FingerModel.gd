extends RefCounted

class_name FingerModel

var _fingerRingModel : FingerRingModel = null
var _handModel : HandModel = null

var destroyed : bool = false

signal before_finger_destroyed()
signal after_finger_destroyed()
signal ring_added(fingerRingModel : FingerRingModel)
signal ring_removed(fingerRingModel : FingerRingModel)
signal ring_replaced(newFingerRingModel : FingerRingModel, oldFingerRingModel : FingerRingModel)

####################################################################################################

func setHandModel(newHandModel : HandModel) -> void:
	self._handModel = newHandModel

func setFingerRingModel(newFingerRingModel : FingerRingModel) -> void:
	if newFingerRingModel == _fingerRingModel:
		return
	var oldFingerRingModel : FingerRingModel = _fingerRingModel
	_fingerRingModel = newFingerRingModel
	_fingerRingModel.setFingerModel(self)
	if oldFingerRingModel == null:
		ring_added.emit(newFingerRingModel)
	elif newFingerRingModel == null:
		ring_removed.emit(oldFingerRingModel)
	else:
		ring_replaced.emit(newFingerRingModel, oldFingerRingModel)

func getFingerRingModel() -> FingerRingModel:
	return _fingerRingModel

func getHandModel() -> HandModel:
	return _handModel

func getPlayerModel() -> PlayerModel:
	if _handModel == null:
		return null
	return _handModel.getPlayerModel()

func destroyFinger() -> void:
	before_finger_destroyed.emit()
	destroyed = true
	after_finger_destroyed.emit()

func clone() -> FingerModel:
	var copy : FingerModel = get_script().new()
	if _fingerRingModel != null:
		copy.setFingerRingModel(_fingerRingModel.clone())
	copy.destroyed = destroyed
	return copy
