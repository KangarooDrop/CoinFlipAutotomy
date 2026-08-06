extends RefCounted

class_name FingerModel

var _ringModel : RingModel = null
var _handModelRef : WeakRef = null

var destroyed : bool = false

signal before_finger_destroyed()
signal after_finger_destroyed()
signal ring_added(ringModel : RingModel)
signal ring_removed(ringModel : RingModel)
signal ring_replaced(newRingModel : RingModel, oldRingModel : RingModel)

####################################################################################################

func setRingModel(newRingModel : RingModel) -> void:
	if newRingModel == _ringModel:
		return
	var oldRingModel : RingModel = _ringModel
	if oldRingModel != null:
		oldRingModel.setFingerModel(null)
	_ringModel = newRingModel
	_ringModel.setFingerModel(self)
	if oldRingModel == null:
		ring_added.emit(newRingModel)
	elif newRingModel == null:
		ring_removed.emit(oldRingModel)
	else:
		ring_replaced.emit(newRingModel, oldRingModel)

func getRingModel() -> RingModel:
	return _ringModel

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
	if _ringModel != null:
		copy.setRingModel(_ringModel.clone())
	copy.destroyed = destroyed
	return copy
