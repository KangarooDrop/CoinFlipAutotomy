extends FingerRingModel

class_name RingVanityRing

func getLocID() -> String: return super.getLocID() + "VANITY_RING"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "vanity_ring.png"
