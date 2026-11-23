extends RingModel

class_name RingCrownOfPrimaeNoctis

####################################################################################################

func getLocID() -> String: return super.getLocID() + "CROWN_OF_PRIMAE_NOCTIS"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "crown_of_primae_noctis.png"

####################################################################################################

func onRoundStart(matchState : MatchState) -> bool:
	popNode()
	var targetCoinPiece : CoinPieceModel = await CmdAction.getTarget(matchState, Entities.TargetType.ABILITY_PIECE_ENEMY, getPlayerModel())
	var abilityScript : Script = targetCoinPiece.abilityScript
	if abilityScript == null:
		return true
	
	await CmdMatch.copyAbilityScriptNewContext(matchState, abilityScript, self)
	return true
