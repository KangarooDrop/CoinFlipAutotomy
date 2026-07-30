@abstract
extends ItemModel

class_name CoinPieceModel

const ABILITY_SCRIPT_KEY : String = "ability_script"
const PIECE_TYPE_KEY : String = "piece_type"

var coinPieceType : Entities.CoinPieceType = Entities.CoinPieceType.NONE
var abilityScript : Script = null

var _sealModel : SealModel = null
var _coinFaceModel : CoinFaceModel = null

var seal_added : CFSignal = CFSignal.new() #(sealModel : SealModel)
var seal_removed : CFSignal = CFSignal.new() #(sealModel : SealModel)
var seal_replaced : CFSignal = CFSignal.new() #(newSealModel : SealModel, oldSealModel : SealModel)

#signal seal_added(sealModel : SealModel)
#signal seal_removed(sealModel : SealModel)
#signal seal_replaced(newSealModel : SealModel, oldSealModel : SealModel)

####################################################################################################

####################################################################################################

func getLocID() -> String: return "COIN_PIECE."

func getTexturePath() -> String:
	return Preloader.texturePath + "CoinParts/"

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		PIECE_TYPE_KEY : Entities.CoinPieceType.NONE,
		ABILITY_SCRIPT_KEY : null,
	}, true)
	return baseData

func deserialize(data : Dictionary) -> LocalizedModel:
	super.deserialize(data)
	if data.has(ABILITY_SCRIPT_KEY):
		abilityScript = data[ABILITY_SCRIPT_KEY]
	if data.has(PIECE_TYPE_KEY):
		coinPieceType = data[PIECE_TYPE_KEY]
	return self

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn.merge({
		ABILITY_SCRIPT_KEY : abilityScript,
		PIECE_TYPE_KEY : coinPieceType,
	}, true)
	return rtn

func getTooltipString() -> String:
	var rtn : String = getLocalizedString("name")
	if abilityScript != null:
		rtn += "\n" + ModelDB.getAbilitySingleton(abilityScript).getTooltipString()
	else:
		"Ability: None"
	if _sealModel != null:
		rtn += "\n" + _sealModel.getTooltipString()
	return rtn

####################################################################################################

func getSealModel() -> SealModel:
	return _sealModel

func getCoinFaceModel() -> CoinFaceModel:
	return _coinFaceModel

func setCoinFaceModel(newCoinFaceModel : CoinFaceModel) -> void:
	_coinFaceModel = newCoinFaceModel

func getPlayerModel() -> PlayerModel:
	if _coinFaceModel == null:
		return null
	return _coinFaceModel.getPlayerModel()

func setSealModel(newSealModel : SealModel) -> SealModel:
	var oldSealModel : SealModel = _sealModel
	if oldSealModel == newSealModel:
		return oldSealModel
	if oldSealModel != null:
		oldSealModel.setCoinPieceModel(null)
	_sealModel = newSealModel
	if newSealModel != null:
		newSealModel.setCoinPieceModel(self)
	if newSealModel == null:
		await seal_removed.emitSignal(oldSealModel)
	elif oldSealModel != null:
		await seal_replaced.emitSignal(newSealModel, oldSealModel)
	else:
		await seal_added.emitSignal(newSealModel)
	return oldSealModel

func removeSealModel() -> void:
	setSealModel(null)

func hasSeal() -> bool:
	return _sealModel != null

func getSocketIndex() -> Entities.CoinPieceSocketIndex:
	if _coinFaceModel != null:
		return _coinFaceModel.getSocketIndexFromCoinPieceModel(self)
	return Entities.CoinPieceSocketIndex.NONE
