extends Ability
class_name AbilityDragToSea

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "DRAG_TO_SEA"

func getTexturePath() -> String:
	return super.getTexturePath() + "drag_to_sea.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.SEAL_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityDragToSea.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityDragToSea.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var targetCoinPieceModel : CoinPieceModel = abilityContext.targets[0]
	if not targetCoinPieceModel.hasSeal():
		push_error("ERROR: Coin Piece with non-Seal given to AbilityDragToSea.activate: " + str(targetCoinPieceModel) + ".")
		return
	
	var brokenSealScript : Script = targetCoinPieceModel.getSealModel().get_script()
	await CmdSeal.removeSeal(matchState, targetCoinPieceModel)
	
	var sourceCoinPiece : CoinPieceModel = null
	if abilityContext.source is CoinPieceModel:
		sourceCoinPiece = abilityContext.source
	if sourceCoinPiece == null:
		return
	
	await CmdSeal.addSeal(matchState, ModelDB.getSeal(brokenSealScript), sourceCoinPiece)
