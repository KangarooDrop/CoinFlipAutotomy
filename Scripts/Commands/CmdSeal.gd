extends Node
class_name CmdSeal

static func addSeal(matchState : MatchState, sealModel : SealModel, coinPieceModel : CoinPieceModel) -> void:
	if coinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with a Seal passed as argument for CmdSeal.addSeal.")
		return
	await setSeal(matchState, sealModel, coinPieceModel)

static func removeSeal(matchState : MatchState, coinPieceModel : CoinPieceModel) -> void:
	if not coinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with no Seal passed as argument for CmdSeal.removeSeal.")
		return
	await setSeal(matchState, null, coinPieceModel)

static func setSeal(matchState : MatchState, sealModel : SealModel, coinPieceModel : CoinPieceModel) -> void:
	var oldSealModel : SealModel = coinPieceModel.getSealModel()
	var newSealModelPointer : Pointer = Pointer.new(sealModel)
	await TriggerHandler.onBeforeSealChanged(matchState, coinPieceModel, newSealModelPointer)
	await coinPieceModel.setSealModel(newSealModelPointer.val)
	await TriggerHandler.onAfterSealChanged(matchState, coinPieceModel, oldSealModel)
