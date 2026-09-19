extends SealModel

class_name SealEmpty

func getLocID() -> String: return super.getLocID() + "EMPTY"

func getTexturePath() -> String:
	return super.getTexturePath() + "empty.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		BACKGROUND_TYPE : Entities.SealBackgroundType.PURPLE,
	}, true)
	return baseData
