extends FingerRingModel

class_name RingCrownOfPrimaeNoctis

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CROWN_OF_PRIMAE_NOCTIS"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "crown_of_primae_noctis.png"

####################################################################################################

func onRoundStart(_matchState : MatchState) -> void:
	var targetCoinPiece : CoinPieceModel = await CmdAction.getAbilityTarget(Entities.AbilityTargetType.COIN_PIECE_ENEMY, getPlayerModel())
	var abilityScript : Script = targetCoinPiece.abilityScript
	if abilityScript == null:
		return
	var matchNode : MatchNode = CmdMatch.getMatchNode()
	await matchNode.activateAbilityScript(abilityScript, self)
