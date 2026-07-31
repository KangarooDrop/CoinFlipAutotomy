@abstract
extends ItemModel

class_name FingerRingModel

var _fingerModelRef : WeakRef = null

####################################################################################################

func getLocID() -> String: return "FINGER_RING."

func getTexturePath() -> String:
	return Preloader.texturePath + "FingerRings/"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func deserialize(data : Dictionary) -> LocalizedModel:
	super.deserialize(data)
	return self

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn.merge({
		
	}, true)
	return rtn

func getTooltipString() -> String:
	return getLocalizedString("name") + ": " + getLocalizedString("desc")

####################################################################################################

func setFingerModel(newFingerModel : FingerModel) -> void:
	_fingerModelRef = weakref(newFingerModel)

func getFingerModel() -> FingerModel:
	if not _fingerModelRef:
		return null
	return _fingerModelRef.get_ref()

func getHandModel() -> HandModel:
	if not _fingerModelRef:
		return null
	return getFingerModel().getHandModel()

func getPlayerModel() -> PlayerModel:
	if not _fingerModelRef:
		return null
	return getFingerModel().getPlayerModel()
