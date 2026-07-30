@abstract
extends LocalizedModel

class_name Ability

const TARGET_TYPE_KEY : String = "target_type"

var targetType : Entities.AbilityTargetType = Entities.AbilityTargetType.NONE

####################################################################################################

func deserialize(data : Dictionary) -> LocalizedModel:
	super.deserialize(data)
	if data.has(TARGET_TYPE_KEY):
		targetType = data[TARGET_TYPE_KEY]
	return self

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn.merge({
		TARGET_TYPE_KEY : targetType,
	}, true)
	return rtn

####################################################################################################

func getLocID() -> String: return "ABILITY."

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.AbilityTargetType.NONE,
	}, true)
	return baseData

func getTexturePath() -> String:
	return Preloader.texturePath + "Abilities/"

@abstract func activate(matchState : MatchState, abilityContext : AbilityContext) -> void

func getTooltipString() -> String:
	return getLocalizedString("name") + ": " + getLocalizedString("desc")

####################################################################################################

func getPlayerModel(abilityContext : AbilityContext) -> PlayerModel:
	if abilityContext.source.has_method("getPlayerModel"):
		return abilityContext.source.getPlayerModel()
	return null
