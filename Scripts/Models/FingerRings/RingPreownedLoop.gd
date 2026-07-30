extends FingerRingModel

class_name RingPreownedLoop

####################################################################################################

func getLocID() -> String: return super.getLocID() + "PREOWNED_LOOP"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "preowned_loop.png"

####################################################################################################

func onRoundStart(_matchState : MatchState) -> void:
	var targetCoinPiece : CoinPieceModel = await CmdAction.getAbilityTarget(Entities.AbilityTargetType.COIN_PIECE_ENEMY, getPlayerModel())
	var abilityScript : Script = targetCoinPiece.abilityScript
	if abilityScript == null:
		return
	var matchNode : MatchNode = CmdMatch.getMatchNode()
	await matchNode.activateAbilityScript(abilityScript, self)
