extends Ability
class_name AbilityTakeWhatsMine

const SPIN_INC_PER_SEAL : int = 10

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "TAKE_WHATS_MINE"

func getTexturePath() -> String:
	return super.getTexturePath() + "take_whats_mine.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [ModelDB.getSealSingleton(SealAquaFortis).getName(), SPIN_INC_PER_SEAL]

####################################################################################################

func getSpinInc(matchState : MatchState) -> int:
	var numSeals : int = getAllCoinPiecesWithSealToBreak(matchState).size()
	return numSeals * SPIN_INC_PER_SEAL

func getAllCoinPiecesWithSealToBreak(matchState : MatchState) -> Array[CoinPieceModel]:
	var rtn : Array[CoinPieceModel] = []
	for playerModel : PlayerModel in matchState.getAllPlayerModels():
		for coinPieceModel : CoinPieceModel in playerModel.getCoinFaceModel().getAllPieces():
			if coinPieceModel.getSealModel() is SealAquaFortis:
				rtn.append(coinPieceModel)
	return rtn

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 0:
		push_error("ERROR: Invalid num targets given to AbilityTakeWhatsMine.activate: " + str(abilityContext.targets.size()) + " != 0.")
		return
	
	var spinInc : int = getSpinInc(matchState)
	for coinPieceToBreak : CoinPieceModel in getAllCoinPiecesWithSealToBreak(matchState):
		if coinPieceToBreak.getSealModel() is SealAquaFortis:
			await CmdSeal.removeSeal(matchState, coinPieceToBreak)
	for playerModel : PlayerModel in matchState.getAllPlayerModels():
		await CmdSpin.addSpin(matchState, playerModel, spinInc)
