extends Node

@onready var coinNode : CoinNode = get_node("%CoinNode")
@onready var coinHolder : Control = get_node("%CoinHolder")
@onready var matchBackground : MatchBackground = get_node("%MatchBackground")

const COIN_NODE_FLIP_TIME_MAX : float = 2.0
const COIN_NODE_FLIP_WAIT : float = 1.0

func _ready() -> void:
	matchBackground.setOffset(Vector2.DOWN * 32.0)
	matchBackground.setScale(lerp(matchBackground.BG_SCALE_MIN, matchBackground.BG_SCALE_MAX, 0.0675))
	
	var demonTypes : Array[Script] = ModelDB.getRandomDemonScriptsNoRepeat(2)
	var coinFaceModelObverse : CoinFaceModel = ModelDB.getDemonSingleton(demonTypes[0]).getStarterData().createCoinFaceModel()
	var coinFaceModelReverse : CoinFaceModel = ModelDB.getDemonSingleton(demonTypes[1]).getStarterData().createCoinFaceModel()
	
	"""
	var coinPieceTypes : Array = [CPCounterweightCore, 
								CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior, 
								CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior]
	var coinFaceModelObverse : CoinFaceModel = CoinFaceModel.new()
	for coinPieceType : Script in coinPieceTypes:
		coinFaceModelObverse.addCoinPieceToNextSocket(ModelDB.getCoinPiece(coinPieceType))
	var coinFaceModelReverse : CoinFaceModel = CoinFaceModel.new()
	for coinPieceType : Script in coinPieceTypes:
		coinFaceModelReverse.addCoinPieceToNextSocket(ModelDB.getCoinPiece(coinPieceType))
	"""
	
	coinNode.setCoinFaceModelUser(coinFaceModelObverse)
	coinNode.setCoinFaceModelOpponent(coinFaceModelReverse)
	coinNode.setObverseModel(coinFaceModelObverse)
	await coinNode.getCoinFaceModelToNode(coinFaceModelObverse).playLockInAnim(0.25)
	onCoinNodeFlipFinished()
	
	#c.rapidFlip(coinFaceModelObverse, 100.0, 0.5, 100)
	
	"""
	var counterweightCore : CPCounterweightCore = ModelDB.getCoinPiece(CPCounterweightCore)
	print(counterweightCore.getLocID() + ".name")
	Localization.setLanguage("spa")
	print(Localization.getLocalizedData(counterweightCore.getLocDataRaw("name")))
	Localization.setLanguage("eng")
	"""

func onCoinNodeFlipFinished() -> void:
	await get_tree().create_timer(COIN_NODE_FLIP_WAIT).timeout
	coinNode.flipToOther(COIN_NODE_FLIP_TIME_MAX).connect(onCoinNodeFlipFinished)

func onPlayPressed() -> void:
	get_tree().change_scene_to_packed(Preloader.characterSelectPacked)

func onSettingsPressed() -> void:
	Settings.showSettings()

func onExitPressed() -> void:
	get_tree().quit()
