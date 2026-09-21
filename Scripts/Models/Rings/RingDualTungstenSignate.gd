extends RingModel

class_name RingDualTungstenSignate

const SPIN_LOSS : int = 20

####################################################################################################

func getLocID() -> String: return super.getLocID() + "DUAL_TUNGSTEN_SIGNATE"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "dual_tungsten_signate.png"

####################################################################################################

func getTooltipString() -> String:
	return super.getTooltipString() % SPIN_LOSS

func onRoundStart(matchState : MatchState) -> void:
	popNode()
	
	var playerModel : PlayerModel = getPlayerModel()
	await CmdSpin.addSpin(matchState, playerModel, -SPIN_LOSS)
	
	var targetCoinPiece : CoinPieceModel = await CmdAction.getCoinPieceToActivate(matchState, playerModel)
	var abilityScript : Script = targetCoinPiece.abilityScript
	if abilityScript == null:
		return
	await CmdMatch.copyAbilityScript(matchState, abilityScript, self)
