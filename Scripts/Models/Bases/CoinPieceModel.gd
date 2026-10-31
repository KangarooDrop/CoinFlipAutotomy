extends ItemModel

class_name CoinPieceModel

const PIECE_TYPE_KEY : String = "piece_type"
const ABILITY_SCRIPT_KEY : String = "ability_script"

const SEAL_KEY : String = "seal_data"
const ABILITY_KEY : String = "ability_data"

var coinPieceType : Entities.CoinPieceType = Entities.CoinPieceType.NONE
var abilityScript : Script = null

var _sealModel : SealModel = null
var _coinFaceModelRef : WeakRef = null

var seal_added : CFSignal = CFSignal.new(CFSignal.WAIT_TYPE_PARALLEL) #(sealModel : SealModel)
var seal_removed : CFSignal = CFSignal.new(CFSignal.WAIT_TYPE_PARALLEL) #(sealModel : SealModel)
var seal_replaced : CFSignal = CFSignal.new(CFSignal.WAIT_TYPE_PARALLEL) #(newSealModel : SealModel, oldSealModel : SealModel)

####################################################################################################

func clone() -> CoinPieceModel:
	var usecs : int = Time.get_ticks_usec()
	var copy : CoinPieceModel = super.clone()
	if hasSeal():
		copy.setSealModel(getSealModel().clone())
		copy.getSealModel().setCoinPieceModel(copy)
	Tracker.addTimeUsecs(Tracker.TRACKING_KEY.COIN_PIECE_SERIALIZE, Time.get_ticks_usec() - usecs)
	return copy

####################################################################################################

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		PIECE_TYPE_KEY : Entities.CoinPieceType.NONE,
		ABILITY_SCRIPT_KEY : null,
	}, true)
	return baseData

func _initBaseData(data : Dictionary) -> void:
	super._initBaseData(data)
	if data.has(ABILITY_SCRIPT_KEY):
		setAbilityScript(data[ABILITY_SCRIPT_KEY])
	if data.has(PIECE_TYPE_KEY):
		coinPieceType = data[PIECE_TYPE_KEY]

func serialize() -> Dictionary:
	var rtn : Dictionary = {}
	if abilityScript != null:
		rtn[ABILITY_KEY] = ModelDB.getAbilitySingleton(abilityScript).serialize()
	if hasSeal():
		rtn[SEAL_KEY] = getSealModel().serialize()
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	super.deserialize(data)
	if data.has(ABILITY_KEY):
		setAbilityScript(ModelDB.getModelFromSerialized(data[ABILITY_KEY]).get_script())
	if data.has(SEAL_KEY):
		setSealModel(ModelDB.getModelFromSerialized(data[SEAL_KEY]))
	return self

func getTooltipString() -> String:
	var rtn : String = ""
	if abilityScript != null:
		rtn += ModelDB.getAbilitySingleton(abilityScript).getTooltipString()
	else:
		"Ability: None"
	if _sealModel != null:
		rtn += "\n" + _sealModel.getTooltipString()
	return rtn
	
func getTexturePath() -> String:
	if abilityScript == null:
		return ""
	else:
		return ModelDB.getAbilitySingleton(abilityScript).getTexturePath()

func getLocID() -> String:
	return ModelDB.getAbilitySingleton(abilityScript).getLocID()

func setAbilityScript(newAbilityScript : Script) -> CoinPieceModel:
	abilityScript = newAbilityScript
	texPath = ""
	if abilityScript != null:
		var abilitySingleton : Ability = ModelDB.getAbilitySingleton(abilityScript)
		coinPieceType = abilitySingleton.coinPieceType
		texPath = abilitySingleton.getTexturePath()
	_textureAtlas = null
	return self

####################################################################################################

func canActivateAbilityOfCoinPiece(matchState : MatchState, coinPieceModel : CoinPieceModel) -> bool:
	if coinPieceModel == self:
		if abilityScript != null:
			return ModelDB.getAbilitySingleton(coinPieceModel.abilityScript).canActivateAbilityOfCoinPiece(matchState, coinPieceModel)
		else:
			return false
	return true
	
####################################################################################################

func getSealModel() -> SealModel:
	return _sealModel

func setCoinFaceModel(newCoinFaceModel : CoinFaceModel) -> void:
	_coinFaceModelRef = weakref(newCoinFaceModel)

func getCoinFaceModel() -> CoinFaceModel:
	if not _coinFaceModelRef:
		return null
	var rtn = _coinFaceModelRef.get_ref()
	return rtn

func getPlayerModel() -> PlayerModel:
	if not _coinFaceModelRef:
		return null
	return getCoinFaceModel().getPlayerModel()

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
	if not _coinFaceModelRef:
		return Entities.CoinPieceSocketIndex.NONE
	return getCoinFaceModel().getSocketIndexFromCoinPieceModel(self)
