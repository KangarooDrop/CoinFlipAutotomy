extends RingModel

class_name RingCircleOfLeeches

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CIRCLE_OF_LEECHES"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "circle_of_leeches.png"

func getTooltipString() -> String:
	var cleansingSealName : String = ModelDB.getSeal(SealCleansing).getLocalizedString("name")
	var leadSealName : String = ModelDB.getSeal(SealLead).getLocalizedString("name")
	return super.getTooltipString() % [cleansingSealName, cleansingSealName, leadSealName]

####################################################################################################

func onAfterAbilityActivated(matchState : MatchState, _ability : Ability, context : AbilityContext) -> void:
	if context.source.getPlayerModel() != getPlayerModel():
		return
	if not context.source is CoinPieceModel:
		return
	var sourceCoinPieceModel : CoinPieceModel = context.source as CoinPieceModel
	if sourceCoinPieceModel.getSealModel() != null:
		return
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCleansing), sourceCoinPieceModel)

func onAfterSealChanged(matchState : MatchState, coinPieceModel : CoinPieceModel, oldSealModel : SealModel) -> void:
	if coinPieceModel.getPlayerModel() != getPlayerModel():
		return
	if not oldSealModel is SealCleansing:
		return
	if coinPieceModel.getSealModel() != null:
		return
	
	popNode()
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), coinPieceModel)
