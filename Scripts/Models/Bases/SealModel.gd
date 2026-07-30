@abstract
extends Triggerable

class_name SealModel

const TEXTURE_KEY : String = "texture"
const TEX_PATH_KEY : String = "tex_path"
const BACKGROUND_TYPE : String = "bg_type"

var _texture : Texture2D = null
var texPath : String = getTexturePath()
var _bgType : Entities.SealBackgroundType = Entities.SealBackgroundType.PINK

var _coinPieceModel : CoinPieceModel = null

####################################################################################################

####################################################################################################

func getLocID() -> String: return "SEAL."

func getBaseData() -> Dictionary:
	var baseData : Dictionary = super.getBaseData()
	baseData.merge(
	{
		TEXTURE_KEY : _texture,
		TEX_PATH_KEY : texPath,
		BACKGROUND_TYPE : _bgType,
	}, true)
	return baseData

func getTexturePath() -> String:
	return Preloader.texturePath + "Seals/"

func deserialize(data : Dictionary) -> LocalizedModel:
	super.deserialize(data)
	if data.has(TEXTURE_KEY):
		_texture = data[TEXTURE_KEY]
	if data.has(TEX_PATH_KEY):
		texPath = data[TEX_PATH_KEY]
	if data.has(BACKGROUND_TYPE):
		_bgType = data[BACKGROUND_TYPE]
	return self

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn.merge({
		TEXTURE_KEY : _texture,
		TEX_PATH_KEY : texPath,
		BACKGROUND_TYPE : _bgType,
	}, true)
	return rtn

func getTooltipString() -> String:
	return getLocalizedString("name") + ": " + getLocalizedString("desc")

####################################################################################################

func setCoinPieceModel(newCoinPieceModel : CoinPieceModel) -> void:
	_coinPieceModel = newCoinPieceModel

func getCoinPieceModel() -> CoinPieceModel:
	return _coinPieceModel

func getPlayerModel() -> PlayerModel:
	if _coinPieceModel == null:
		return null
	return _coinPieceModel.getPlayerModel()

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
