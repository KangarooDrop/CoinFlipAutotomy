extends Ability
class_name AbilityMock

func getLocID() -> String: 
	return super.getLocID() + "MOCK"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
	}, true)
	return baseData

func activate(_matchState : MatchState, _abilityContext : AbilityContext) -> void:
	pass
