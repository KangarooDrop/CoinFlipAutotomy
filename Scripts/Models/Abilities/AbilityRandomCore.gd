extends Ability
class_name AbilityRandomCore

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "RANDOM_CORE"

func getTexturePath() -> String:
	return super.getTexturePath() + "random_core.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.CORE,
		IS_VISIBLE_KEY : false,
	}, true)
	return baseData

func getTooltipString() -> String:
	return super.getTooltipString()

####################################################################################################

func activate(_matchState : MatchState, _abilityContext : AbilityContext) -> void:
	pass
