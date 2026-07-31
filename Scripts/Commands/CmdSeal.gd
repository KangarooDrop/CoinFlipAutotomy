extends Node

func addSeal(matchState : MatchState, sealModel : SealModel, coinPieceModel : CoinPieceModel) -> void:
	if coinPieceModel.hasSeal():
		return
	await setSeal(matchState, sealModel, coinPieceModel)

func removeSeal(matchState : MatchState, coinPieceModel : CoinPieceModel) -> void:
	if not coinPieceModel.hasSeal():
		return
	await setSeal(matchState, null, coinPieceModel)

func setSeal(matchState : MatchState, sealModel : SealModel, coinPieceModel : CoinPieceModel) -> void:
	var oldSealModel : SealModel = coinPieceModel.getSealModel()
	var newSealModelPointer : Pointer = Pointer.new(sealModel)
	await TriggerHandler.onBeforeSealChanged(matchState, coinPieceModel, newSealModelPointer)
	await coinPieceModel.setSealModel(newSealModelPointer.val)
	await TriggerHandler.onAfterSealChanged(matchState, coinPieceModel, oldSealModel)
