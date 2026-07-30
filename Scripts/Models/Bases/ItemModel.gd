@abstract
extends Triggerable

class_name ItemModel

const TEXTURE_ATLAS_KEY : String = "texture_atlas"
const TEX_PATH_KEY : String = "tex_path"

var _textureAtlas : Texture2D = null
var texPath : String = getTexturePath()

####################################################################################################

@abstract func getTexturePath() -> String

func deserialize(data : Dictionary) -> LocalizedModel:
	super.deserialize(data)
	if data.has(TEXTURE_ATLAS_KEY):
		_textureAtlas = data[TEXTURE_ATLAS_KEY]
	if data.has(TEX_PATH_KEY):
		texPath = data[TEX_PATH_KEY]
	return self

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn.merge({
		TEXTURE_ATLAS_KEY : _textureAtlas,
		TEX_PATH_KEY : texPath,
	}, true)
	return rtn

####################################################################################################

func getTextureAtlas() -> Texture2D:
	if _textureAtlas == null:
		if texPath.is_empty():
			push_error("ERROR: No texture path given to ItemModel")
			return null
		else:
			_textureAtlas = load(texPath)
	return _textureAtlas
