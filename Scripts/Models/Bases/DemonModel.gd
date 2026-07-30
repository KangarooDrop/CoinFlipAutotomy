@abstract
extends LocalizedModel

class_name DemonModel

var handAtlas : Texture2D = null
var portraitTexture : Texture2D = null
var poseTexture : Texture2D = null
var rotDataArr : Array[FingerRingRotData] = []

####################################################################################################

func _init(_data : Dictionary = {}) -> void:
	handAtlas = load(getHandAtlasPath())
	portraitTexture = load(getPortraitPath())
	poseTexture = load(getPosePath())
	rotDataArr = getRotData()

####################################################################################################

func getLocID() -> String: return "DEMON."

@abstract func getDirName() -> String

func getStartingCoinPieceTypes() -> Array[Script]: return []

func getStartingFingerRingTypes() -> Array[Script]: return []

func getRotData() -> Array[FingerRingRotData]:
	return [
		FingerRingRotData.new(Vector2i(-28, -30), 0),
		FingerRingRotData.new(Vector2i(17, -16), 1),
		FingerRingRotData.new(Vector2i(21, 2), 1),
		FingerRingRotData.new(Vector2i(17, 17), 1),
		FingerRingRotData.new(Vector2i(12, 32), 1),
	]

####################################################################################################

func getDirParentPath() -> String:
	return Preloader.texturePath + "/Demons/"
func getHandAtlasPath() -> String:
	return getDirParentPath() + getDirName() + "/hand_atlas.png"
func getPortraitPath() -> String:
	return getDirParentPath() + getDirName() + "/portrait.png"
func getPosePath() -> String:
	return getDirParentPath() + getDirName() + "/pose.png"

func getNumFingers() -> int:
	return rotDataArr.size()

func getStarterData() -> StarterData:
	return StarterData.new(self, getStartingCoinPieceTypes(), getStartingFingerRingTypes())

func getName() -> String:
	return getLocalizedString("name")

func getEpithet() -> String:
	return getLocalizedString("epithet")

func getWinSplash() -> String:
	return getLocalizedString("win_splash")
