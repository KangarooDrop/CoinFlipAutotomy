extends RefCounted

class_name FingerModel

var _fingerRingModel : FingerRingModel = null
var _handModelRef : WeakRef = null

var destroyed : bool = false

signal before_finger_destroyed()
signal after_finger_destroyed()
signal ring_added(fingerRingModel : FingerRingModel)
signal ring_removed(fingerRingModel : FingerRingModel)
signal ring_replaced(newFingerRingModel : FingerRingModel, oldFingerRingModel : FingerRingModel)

####################################################################################################

func setFingerRingModel(newFingerRingModel : FingerRingModel) -> void:
	if newFingerRingModel == _fingerRingModel:
		return
	var oldFingerRingModel : FingerRingModel = _fingerRingModel
	if oldFingerRingModel != null:
		oldFingerRingModel.setFingerModel(null)
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

func setHandModel(newHandModel : HandModel) -> void:
	_handModelRef = weakref(newHandModel)

func getHandModel() -> HandModel:
	if not _handModelRef:
		return null
	return _handModelRef.get_ref()

func getPlayerModel() -> PlayerModel:
	if not _handModelRef:
		return null
	return getHandModel().getPlayerModel()

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
