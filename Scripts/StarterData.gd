extends RefCounted

class_name StarterData

var sourceDemon = null
var startingCoinPieceTypes : Array[Script] = []
var startingFingerRingTypes : Array[Script] = []

func _init(demon, coinPieceTypes : Array[Script], fingerRingTypes : Array[Script]) -> void:
	sourceDemon = demon
	startingCoinPieceTypes = coinPieceTypes
	startingFingerRingTypes = fingerRingTypes

func createHandModel() -> HandModel:
	var handModel : HandModel = HandModel.new(sourceDemon)
	for ringType : Script in startingFingerRingTypes:
		handModel.addFingerRing(ModelDB.getFingerRing(ringType))
	return handModel

func createCoinFaceModel() -> CoinFaceModel:
	var coinFaceModel : CoinFaceModel = CoinFaceModel.new()
	for coinPieceType : Script in startingCoinPieceTypes:
		coinFaceModel.addCoinPieceToNextSocket(ModelDB.getCoinPiece(coinPieceType))
	return coinFaceModel

func createPlayerModel() -> PlayerModel:
	return PlayerModel.new(sourceDemon, createHandModel(), createCoinFaceModel())
