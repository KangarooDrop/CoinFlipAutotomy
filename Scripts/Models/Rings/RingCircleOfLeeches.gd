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

func onAfterAbilityActivated(matchState : MatchState, _ability : Ability, context : AbilityContext) -> bool:
	if context.source.getPlayerModel() != getPlayerModel():
		return false
	if not context.source is CoinPieceModel:
		return false
	var sourceCoinPieceModel : CoinPieceModel = context.source as CoinPieceModel
	if sourceCoinPieceModel.getSealModel() != null:
		return false
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCleansing), sourceCoinPieceModel)
	return true

func onAfterSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, oldSealModel : SealModel) -> bool:
	if coinPieceModel.getPlayerModel() != getPlayerModel():
		return false
	if not oldSealModel is SealCleansing:
		return false
	if coinPieceModel.getSealModel() != null:
		return false
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), coinPieceModel)
	return true
