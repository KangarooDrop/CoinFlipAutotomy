extends Serializable

class_name HandModel

const DEMON_DATA_KEY : String = "demon_data"
const FINGER_DATA_KEY : String = "finger_data"

var _demonScript : Script = null
var _fingerModels : Array[FingerModel] = []

var _playerModelRef : WeakRef = null

####################################################################################################

func setDemonScript(newDemonScript : Script) -> void:
	_demonScript = newDemonScript
	for i in range(ModelDB.getDemonSingleton(_demonScript).getTotalNumFingers()):
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

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn[DEMON_DATA_KEY] = ModelDB.getDemonSingleton(_demonScript).serialize()
	rtn[FINGER_DATA_KEY] = []
	for i in range(getTotalNumFingers()):
		rtn[FINGER_DATA_KEY].append(getFinger(i).serialize())
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	super.deserialize(data)
	setDemonScript(ModelDB.getModelFromSerialized(data[DEMON_DATA_KEY]).get_script())
	for i in range(data[FINGER_DATA_KEY].size()):
		getFinger(i).deserialize(data[FINGER_DATA_KEY][i])
		getFinger(i).setHandModel(self)
	return self

####################################################################################################

func setPlayerModel(newPlayerModel : PlayerModel) -> void:
	_playerModelRef = weakref(newPlayerModel)

func getPlayerModel() -> PlayerModel:
	if not _playerModelRef:
		return null
	return _playerModelRef.get_ref()

func getDemonScript() -> Script:
	return _demonScript

func getTextureAtlas() -> Texture2D:
	return ModelDB.getDemonSingleton(_demonScript).handAtlas

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
	return ModelDB.getDemonSingleton(_demonScript).rotDataArr

func getTotalNumFingers() -> int:
	return ModelDB.getDemonSingleton(_demonScript).rotDataArr.size()

func getNextRingIndex() -> int:
	for i in range(getTotalNumFingers()):
		if _fingerModels[i].getRingModel() == null and not _fingerModels[i].destroyed:
			return i
	return -1

func canAddRing() -> bool:
	return getNextRingIndex() != -1

func addRing(ringModel : RingModel) -> bool:
	var nextIndex : int = getNextRingIndex()
	if nextIndex != -1:
		getFinger(nextIndex).setRingModel(ringModel)
		return true
	return false

func eraseRing(ringModel : RingModel) -> bool:
	for i in getTotalNumFingers():
		var fingerModel : FingerModel = getFinger(i)
		if fingerModel.getRingModel() == ringModel:
			fingerModel.setRingModel(null)
			return true
	return false

func getFinger(index : int) -> FingerModel:
	if not _hasIndex(index):
		push_error("ERROR: Invalid index given to getFinger")
		return null
	return _fingerModels[index]

func getRemainingNumFingers() -> int:
	var rem : int = 0
	for fingerModel : FingerModel in _fingerModels:
		if not fingerModel.destroyed:
			rem += 1
	return rem

func areAllFingersDestroyed() -> bool:
	for fingerModel : FingerModel in _fingerModels:
		if not fingerModel.destroyed:
			return false
	return true

func getRingIndex(ringModel : RingModel) -> int:
	for i in range(getTotalNumFingers()):
		if _fingerModels[i].getRingModel() == ringModel:
			return i
	return -1
