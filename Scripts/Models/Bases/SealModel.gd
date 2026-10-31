@abstract
extends Triggerable

class_name SealModel

const TEXTURE_KEY : String = "texture"
const TEX_PATH_KEY : String = "tex_path"
const BACKGROUND_TYPE : String = "bg_type"

var _texture : Texture2D = null
var texPath : String = getTexturePath()
var _bgType : Entities.SealBackgroundType = Entities.SealBackgroundType.PINK

var _coinPieceModelRef : WeakRef = null

####################################################################################################

####################################################################################################

func getLocID() -> String: return "SEAL."

func getTexturePath() -> String:
	return Preloader.texturePath + "Seals/"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		TEXTURE_KEY : _texture,
		TEX_PATH_KEY : texPath,
		BACKGROUND_TYPE : _bgType,
	}, true)
	return baseData

func _initBaseData(data : Dictionary) -> void:
	super._initBaseData(data)
	if data.has(TEXTURE_KEY):
		_texture = data[TEXTURE_KEY]
	if data.has(TEX_PATH_KEY):
		texPath = data[TEX_PATH_KEY]
	if data.has(BACKGROUND_TYPE):
		_bgType = data[BACKGROUND_TYPE]

func getName() -> String:
	return getLocalizedString("name") + " Seal"

func getTooltipString() -> String:
	return getName() + ": " + getLocalizedString("desc")

####################################################################################################

func setCoinPieceModel(newCoinPieceModel : CoinPieceModel) -> void:
	_coinPieceModelRef = weakref(newCoinPieceModel)

func getCoinPieceModel() -> CoinPieceModel:
	if not _coinPieceModelRef:
		return null
	var rtn = _coinPieceModelRef.get_ref()
	return rtn

func getPlayerModel() -> PlayerModel:
	if not _coinPieceModelRef:
		return null
	return getCoinPieceModel().getPlayerModel()

func getTexture() -> Texture2D:
	if _texture == null:
		if texPath.is_empty():
			push_error("ERROR: No texture path given to SealModel")
			return null
		else:
			_texture = load(texPath)
	return _texture

func getBackgroundType() -> Entities.SealBackgroundType:
	return _bgType
