extends Ability
class_name AbilityCounterweightCore

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "COUNTERWEIGHT_CORE"

func getTexturePath() -> String:
	return super.getTexturePath() + "counterweight_core.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
		IS_VISIBLE_KEY : false,
	}, true)
	return baseData

####################################################################################################

func canActivateAbilityOfCoinPiece(_matchState : MatchState, _coinPieceModel : CoinPieceModel) -> bool:
	return false

func activate(_matchState : MatchState, _abilityContext : AbilityContext) -> void:
	pass
