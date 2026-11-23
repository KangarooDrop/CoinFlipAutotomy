extends RingModel

class_name RingCircleOfLeeches

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CIRCLE_OF_LEECHES"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "circle_of_leeches.png"

func getTooltipString() -> String:
	var cleansingSealName : String = ModelDB.getSeal(SealCleansing).getName()
	var leadSealName : String = ModelDB.getSeal(SealLead).getName()
	return super.getTooltipString() % [cleansingSealName, cleansingSealName, leadSealName]

####################################################################################################

func onAfterAbilityActivated(matchState : MatchState, ability : Ability) -> bool:
	if ability.abilityContext.getPlayerModel() != getPlayerModel():
		return false
	if not ability.abilityContext.source is CoinPieceModel:
		return false
	var sourceCoinPieceModel : CoinPieceModel = ability.abilityContext.source as CoinPieceModel
	if sourceCoinPieceModel.getSealModel() != null:
		return false
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCleansing), sourceCoinPieceModel, self)
	return true

func onAfterSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, oldSealModel : SealModel, source : RefCounted) -> bool:
	if coinPieceModel.getPlayerModel() != getPlayerModel():
		return false
	if not oldSealModel is SealCleansing:
		return false
	if coinPieceModel.getSealModel() != null:
		return false
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), coinPieceModel, self)
	return true
