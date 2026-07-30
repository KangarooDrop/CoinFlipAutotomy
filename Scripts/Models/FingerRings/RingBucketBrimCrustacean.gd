extends FingerRingModel

class_name RingBucketBrimCrustacean

const PERCENT_CHANCE : float = 0.1

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BUCKET_BRIM_CRUSTACEAN"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "bucket_brim_crustacean.png"

func getTooltipString() -> String:
	return super.getTooltipString() % Util.toPercent(PERCENT_CHANCE)

####################################################################################################

func onBeforeSpinChanged(matchState : MatchState, playerModel : PlayerModel, amountPointer : Pointer) -> void:
	var myPlayerModel : PlayerModel = getPlayerModel()
	if not matchState.isPlayerTurn(myPlayerModel):
		return
	if playerModel != myPlayerModel:
		return
	if RNG.getRandf() > PERCENT_CHANCE:
		return
	
	amountPointer.val = abs(amountPointer.val)
