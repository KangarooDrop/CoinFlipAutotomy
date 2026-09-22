extends Ability
class_name AbilityHorrorVacui

const SPIN_INC : int = 25

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "HORROR_VACUI"

func getTexturePath() -> String:
	return super.getTexturePath() + "horror_vacui.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [SPIN_INC, ModelDB.getSealSingleton(SealCrystallization).getName()]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 0:
		push_error("ERROR: Invalid num targets given to AbilityHorrorVacui.activate: " + str(abilityContext.targets.size()) + " != 0.")
		return
	
	await CmdSpin.addSpin(matchState, abilityContext.getPlayerModel(), SPIN_INC)
	
	if not abilityContext.source is CoinPieceModel:
		return
	var coinPieceSource : CoinPieceModel = abilityContext.source
	var coinPiecesToStamp : Array[CoinPieceModel] = coinPieceSource.getCoinFaceModel().getAdjacentCoinPieces(coinPieceSource)
	coinPiecesToStamp.insert(0, coinPieceSource)
	for coinPiece : CoinPieceModel in coinPiecesToStamp:
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealCrystallization), coinPiece)
