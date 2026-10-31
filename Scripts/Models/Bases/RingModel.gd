@abstract
extends ItemModel

class_name RingModel

var _fingerModelRef : WeakRef = null

####################################################################################################

func getLocID() -> String: return "RING."

func getTexturePath() -> String:
	return Preloader.texturePath + "Rings/"

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
