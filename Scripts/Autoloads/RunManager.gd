extends Node

const NUM_TOKENS_ON_START : int = 1
const NUM_LIVES_ON_START : int = 5
const NUM_TOKENS_PER_MATCH : int = 2

var _userPlayerModel : PlayerModel = null
var _numTokens : int = NUM_TOKENS_ON_START
var _numLives : int = NUM_LIVES_ON_START

signal num_lives_changed()
signal num_tokens_changed()

####################################################################################################

func getUserPlayerModel() -> PlayerModel:
	return _userPlayerModel

func setNumTokens(val : int) -> void:
	_numTokens = val
	num_tokens_changed.emit()

func addNumTokens(amount : int) -> void:
	setNumTokens(_numTokens + amount)

func getNumTokens() -> int:
	return _numTokens

func setNumLives(val : int) -> void:
	_numLives = val
	num_lives_changed.emit()

func addNumLives(amount : int) -> void:
	setNumLives(_numLives + amount)

func getNumLives() -> int:
	return _numLives

####################################################################################################

func randomizeCoinPieces() -> void:
	var coinFaceModel : CoinFaceModel = _userPlayerModel.getOriginalCoinFaceModel()
	var isCoreRandom : bool = coinFaceModel.getCoinPieceAtSocket(Entities.CoinPieceSocketIndex.CORE).abilityScript == AbilityRandomCore
	var randomExteriorSocketIndices : Array[Entities.CoinPieceSocketIndex] = []
	for socketIndex : Entities.CoinPieceSocketIndex in coinFaceModel.getUsedSocketIndices():
		if socketIndex == Entities.CoinPieceSocketIndex.CORE:
			continue
		var coinPieceModel : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(socketIndex)
		if coinPieceModel.abilityScript != AbilityRandomExterior:
			continue
		randomExteriorSocketIndices.append(socketIndex)
	if isCoreRandom:
		coinFaceModel.getCoinPieceAtSocket(Entities.CoinPieceSocketIndex.CORE).setAbilityScript(ModelDB.getRandomAbilityCoreScript())
	if randomExteriorSocketIndices.size() > 0:
		var abilityScripts : Array[Script] = ModelDB.getRandomAbilityExteriorScriptsNoRepeat(randomExteriorSocketIndices.size())
		for i in range(randomExteriorSocketIndices.size()):
			coinFaceModel.getCoinPieceAtSocket(randomExteriorSocketIndices[i]).setAbilityScript(abilityScripts[i])

func onCharacterChosen(demonScript : Script) -> void:
	_userPlayerModel = ModelDB.getDemonSingleton(demonScript).getStarterData().createPlayerModel()
	_userPlayerModel.isHuman = true
	randomizeCoinPieces()
	
	#get_tree().change_scene_to_packed(Preloader.matchNodePacked)
	get_tree().change_scene_to_packed(Preloader.venderPacked)

func onMatchEnded(matchState : MatchState) -> void:
	if not matchState.winningPlayers.has(_userPlayerModel):
		var numFingersLeft : int = _userPlayerModel.getHandModel().getRemainingNumFingers()
		setNumLives(getNumLives() - numFingersLeft)
	if getNumLives() > 0:
		addNumTokens(NUM_TOKENS_PER_MATCH)
		get_tree().change_scene_to_packed(Preloader.venderPacked)

func onVenderExited() -> void:
	_userPlayerModel.getOriginalCoinFaceModel().fillEmptySockets()
	get_tree().change_scene_to_packed(Preloader.matchNodePacked)
