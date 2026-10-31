@abstract
extends Triggerable

class_name ItemModel

const TEXTURE_ATLAS_KEY : String = "texture_atlas"
const TEX_PATH_KEY : String = "tex_path"

var _textureAtlas : Texture2D = null
var texPath : String = getTexturePath()

####################################################################################################

@abstract func getTexturePath() -> String

####################################################################################################

func getTextureAtlas() -> Texture2D:
	if _textureAtlas == null:
		if texPath.is_empty():
			push_error("ERROR: No texture path given to ItemModel")
			return null
		else:
			_textureAtlas = load(texPath)
	return _textureAtlas
