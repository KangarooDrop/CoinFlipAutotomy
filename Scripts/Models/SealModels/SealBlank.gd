extends SealModel

class_name SealBlank

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BLANK"

func getTexturePath() -> String:
	return super.getTexturePath() + "blank.png"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.PURPLE,
	}, true)
	return baseData

####################################################################################################
