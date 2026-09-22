@abstract
extends LocalizedModel

class_name Ability

const TARGET_TYPE_KEY : String = "target_type"
const PIECE_TYPE_KEY : String = "piece_type"

var targetType : Entities.TargetType = Entities.TargetType.NONE
var coinPieceType : Entities.CoinPieceType = Entities.CoinPieceType.NONE

####################################################################################################

func deserialize(data : Dictionary) -> LocalizedModel:
	super.deserialize(data)
	if data.has(TARGET_TYPE_KEY):
		targetType = data[TARGET_TYPE_KEY]
	if data.has(PIECE_TYPE_KEY):
		coinPieceType = data[PIECE_TYPE_KEY]
	return self

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn.merge({
		TARGET_TYPE_KEY : targetType,
		PIECE_TYPE_KEY : coinPieceType,
	}, true)
	return rtn

####################################################################################################

func getLocID() -> String: return "ABILITY."

func getTexturePath() -> String:
	return Preloader.texturePath + "CoinParts/"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.NONE,
	}, true)
	return baseData

@abstract func activate(matchState : MatchState, abilityContext : AbilityContext) -> void

func getTooltipString() -> String:
	return getLocalizedString("name") + ": " + getLocalizedString("desc")

func canActivateAbilityOfCoinPiece(_matchState : MatchState, _coinPieceModel : CoinPieceModel) -> bool:
	return true

####################################################################################################
