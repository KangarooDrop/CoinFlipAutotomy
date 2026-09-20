extends Ability
class_name AbilityWait

####################################################################################################

func getLocID() -> String: 
	return super.getLocID() + "WAIT"

func getTexturePath() -> String:
	return super.getTexturePath() + "wait.png"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.EXTERIOR,
	}, true)
	return baseData

####################################################################################################

func activate(_matchState : MatchState, _abilityContext : AbilityContext) -> void:
	pass
