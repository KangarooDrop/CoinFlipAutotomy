@abstract
extends ItemModel

class_name FingerRingModel

var _fingerModel : FingerModel = null

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
	_fingerModel = newFingerModel

func getFingerModel() -> FingerModel:
	return _fingerModel

func getHandModel() -> HandModel:
	if _fingerModel == null:
		return null
	return _fingerModel.getHandModel()

func getPlayerModel() -> PlayerModel:
	if _fingerModel == null:
		return null
	return _fingerModel.getPlayerModel()
