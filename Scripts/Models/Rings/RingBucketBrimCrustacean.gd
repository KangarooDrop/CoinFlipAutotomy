extends RingModel

class_name RingBucketBrimCrustacean

const PERCENT_CHANCE : float = 0.1

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BUCKET_BRIM_CRUSTACEAN"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "bucket_brim_crustacean.png"

func getTooltipString() -> String:
	return super.getTooltipString() % Util.toPercent(PERCENT_CHANCE)

####################################################################################################

func onBeforeSpinChanged(matchState : MatchState, playerModel : PlayerModel, amountPointer : Pointer) -> bool:
	var myPlayerModel : PlayerModel = getPlayerModel()
	if not matchState.isPlayerTurn(myPlayerModel):
		return false
	if playerModel != myPlayerModel:
		return false
	if not RNG.selectRate(matchState, PERCENT_CHANCE):
		return false
	
	popNode()
	amountPointer.val = abs(amountPointer.val)
	return true
