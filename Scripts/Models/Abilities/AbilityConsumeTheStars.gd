extends Ability
class_name AbilityConsumeTheStars

const SPIN_PER_BREAK : int = 5
const BREAKS_TO_STAMP : int = 4

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "CONSUME_THE_STARS"

func getTexturePath() -> String:
	return super.getTexturePath() + "consume_the_stars.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.COIN_PIECE_ANY,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString() % [SPIN_PER_BREAK, BREAKS_TO_STAMP, ModelDB.getSealSingleton(SealLead).getName()]

####################################################################################################

func activate(matchState : MatchState, abilityContext : AbilityContext) -> void:
	if abilityContext.targets.size() != 1:
		push_error("ERROR: Invalid num targets given to AbilityRipTide.activate: " + str(abilityContext.targets.size()) + " != 1.")
		return
	if not abilityContext.targets[0] is CoinPieceModel:
		push_error("ERROR: Invalid target given to AbilityRipTide.activate: " + str(abilityContext.targets[0]) + ".")
		return
	
	var coinPieceTarget : CoinPieceModel = abilityContext.targets[0]
	var coinFaceTarget : CoinFaceModel = coinPieceTarget.getCoinFaceModel()
	
	var socketIndexTarget : Entities.CoinPieceSocketIndex = coinPieceTarget.getSocketIndex()
	var socketIndicesToBreak : Array[Entities.CoinPieceSocketIndex] = Entities.CoinPieceSocketScript.getAllAdjacent(socketIndexTarget)
	socketIndicesToBreak.insert(0, socketIndexTarget)
	
	var breakCounter : int = 0
	for socketIndex : Entities.CoinPieceSocketIndex in socketIndicesToBreak:
		var coinPieceToBreak : CoinPieceModel = coinFaceTarget.getCoinPieceAtSocket(socketIndex)
		if coinPieceToBreak == null:
			continue
		var sealModelToBreak : SealModel = coinPieceToBreak.getSealModel()
		if sealModelToBreak == null:
			continue
		await CmdSeal.removeSeal(matchState, coinPieceToBreak)
		breakCounter += 1
	
	var playerModel : PlayerModel = getPlayerModel(abilityContext)
	await CmdSpin.addSpin(matchState, playerModel, SPIN_PER_BREAK * breakCounter)
	
	if breakCounter >= BREAKS_TO_STAMP:
		var stampTarget : CoinPieceModel = await CmdAction.getTarget(matchState, Entities.TargetType.NON_SEAL_ANY, playerModel)
		if stampTarget == null:
			return
		await CmdSeal.addSeal(matchState, ModelDB.getSeal(SealLead), stampTarget)
