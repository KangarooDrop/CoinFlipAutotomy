extends RefCounted

class_name HandModel

var _demon : DemonModel = null
var _fingerModels : Array[FingerModel] = []

var _playerModelRef : WeakRef = null

####################################################################################################

func _init(demon : DemonModel) -> void:
	_demon = demon
	for i in range(demon.getNumFingers()):
		var fingerModel : FingerModel = FingerModel.new()
		fingerModel.setHandModel(self)
		_fingerModels.append(fingerModel)

func _setFingerInternal(index : int, newFingerModel : FingerModel) -> FingerModel:
	var oldFingerModel : FingerModel = getFinger(index)
	if oldFingerModel != null:
		oldFingerModel.setHandModel(null)
	_fingerModels[index] = newFingerModel
	if newFingerModel != null:
		newFingerModel.setHandModel(self)
	return oldFingerModel

func _hasIndex(index : int) -> bool:
	return index >= 0 and index < _fingerModels.size()

####################################################################################################

func clone() -> HandModel:
	var cloneModel : HandModel = get_script().new(_demon)
	cloneModel.setPlayerModel(getPlayerModel())
	for i in range(_fingerModels.size()):
		if _fingerModels[i] == null:
			continue
		cloneModel._setFingerInternal(i, _fingerModels[i].clone())
	return cloneModel

####################################################################################################

func setPlayerModel(newPlayerModel : PlayerModel) -> void:
	_playerModelRef = weakref(newPlayerModel)

func getPlayerModel() -> PlayerModel:
	if not _playerModelRef:
		return null
	return _playerModelRef.get_ref()

func getTextureAtlas() -> Texture2D:
	return _demon.handAtlas

func getFingers() -> Array[FingerModel]:
	return _fingerModels

func getRings() -> Array[RingModel]:
	var rtn : Array[RingModel] = []
	for i in range(_fingerModels.size()):
		if _fingerModels[i].destroyed:
			continue
		var ringModel : RingModel = _fingerModels[i].getRingModel()
		if ringModel != null:
			rtn.append(ringModel)
	return rtn

func getRotData() -> Array[RingRotData]:
	return _demon.rotDataArr

func getNumFingers() -> int:
	return _demon.rotDataArr.size()

func getNextRingIndex() -> int:
	for i in range(getNumFingers()):
		if _fingerModels[i].getRingModel() == null and not _fingerModels[i].destroyed:
			return i
	return -1

func addRing(ringModel : RingModel) -> bool:
	var nextIndex : int = getNextRingIndex()
	if nextIndex != -1:
		getFinger(nextIndex).setRingModel(ringModel)
		return true
	return false

func getFinger(index : int) -> FingerModel:
	if not _hasIndex(index):
		push_error("ERROR: Invalid index given to getFinger")
		return null
	return _fingerModels[index]

func areAllFingersDestroyed() -> bool:
	for fingerModel : FingerModel in _fingerModels:
		if not fingerModel.destroyed:
			return false
	return true
