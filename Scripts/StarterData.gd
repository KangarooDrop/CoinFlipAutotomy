extends RefCounted

class_name StarterData

var sourceDemon = null
var startingCoinPieceTypes : Array[Script] = []
var startingRingTypes : Array[Script] = []

func _init(demon, coinPieceTypes : Array[Script], ringTypes : Array[Script]) -> void:
	sourceDemon = demon
	startingCoinPieceTypes = coinPieceTypes
	startingRingTypes = ringTypes

func createHandModel() -> HandModel:
	var handModel : HandModel = HandModel.new(sourceDemon)
	for ringType : Script in startingRingTypes:
		handModel.addRing(ModelDB.getRing(ringType))
	return handModel

func createCoinFaceModel() -> CoinFaceModel:
	var coinFaceModel : CoinFaceModel = CoinFaceModel.new()
	for coinPieceType : Script in startingCoinPieceTypes:
		coinFaceModel.addCoinPieceToNextSocket(ModelDB.getCoinPiece(coinPieceType))
	return coinFaceModel

func createPlayerModel() -> PlayerModel:
	return PlayerModel.new(sourceDemon, createHandModel(), createCoinFaceModel())
