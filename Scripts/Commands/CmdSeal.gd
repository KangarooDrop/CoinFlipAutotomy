extends Node

func addSeal(sealModel : SealModel, coinPieceModel : CoinPieceModel) -> void:
	if coinPieceModel.hasSeal():
		return
	await setSeal(sealModel, coinPieceModel)

func removeSeal(coinPieceModel : CoinPieceModel) -> void:
	if not coinPieceModel.hasSeal():
		return
	await setSeal(null, coinPieceModel)

func setSeal(sealModel : SealModel, coinPieceModel : CoinPieceModel) -> void:
	var matchState : MatchState = CmdMatch.getMatchState()
	if matchState == null:
		return
	
	var oldSealModel : SealModel = coinPieceModel.getSealModel()
	var newSealModelPointer : Pointer = Pointer.new(sealModel)
	await TriggerHandler.onBeforeSealChanged(matchState, coinPieceModel, newSealModelPointer)
	await coinPieceModel.setSealModel(newSealModelPointer.val)
	await TriggerHandler.onAfterSealChanged(matchState, coinPieceModel, oldSealModel)
