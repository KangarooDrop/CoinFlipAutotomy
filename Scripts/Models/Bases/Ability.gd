@abstract
extends LocalizedModel

class_name Ability

const TARGET_TYPE_KEY : String = "target_type"
const PIECE_TYPE_KEY : String = "piece_type"

var targetType : Entities.TargetType = Entities.TargetType.NONE
var coinPieceType : Entities.CoinPieceType = Entities.CoinPieceType.NONE

####################################################################################################

func getLocID() -> String: return "ABILITY."

func getTexturePath() -> String:
	return Preloader.texturePath + "CoinParts/"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		TARGET_TYPE_KEY : Entities.TargetType.NONE,
		PIECE_TYPE_KEY : Entities.CoinPieceType.NONE,
	}, true)
	return baseData

func _initBaseData(data : Dictionary) -> void:
	super._initBaseData(data)
	if data.has(TARGET_TYPE_KEY):
		targetType = data[TARGET_TYPE_KEY]
	if data.has(PIECE_TYPE_KEY):
		coinPieceType = data[PIECE_TYPE_KEY]

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	super.deserialize(data)
	return self

@abstract func activate(matchState : MatchState, abilityContext : AbilityContext) -> void

func getTooltipString() -> String:
	return getLocalizedString("name") + ": " + getLocalizedString("desc")

func canActivateAbilityOfCoinPiece(_matchState : MatchState, _coinPieceModel : CoinPieceModel) -> bool:
	return true

####################################################################################################
