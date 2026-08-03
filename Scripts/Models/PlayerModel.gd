extends RefCounted

class_name PlayerModel

var isHuman : bool = false
var _demon : DemonModel = null
var _handModelOriginal : HandModel = null
var _coinFaceModelOriginal : CoinFaceModel = null

var _handModelMatch : HandModel = null
var _coinFaceModelMatch : CoinFaceModel = null

func _init(demon : DemonModel, handModel : HandModel, coinFaceModel : CoinFaceModel) -> void:
	_demon = demon
	_handModelOriginal = handModel
	_handModelOriginal.setPlayerModel(self)
	_coinFaceModelOriginal = coinFaceModel
	_coinFaceModelOriginal.setPlayerModel(self)

func resetMatchCoinFaceModel() -> void:
	_coinFaceModelMatch = _coinFaceModelOriginal.clone()

func resetMatchHandModel() -> void:
	_handModelMatch = _handModelOriginal.clone()

func getDemon() -> DemonModel:
	return _demon

func getHandModel() -> HandModel:
	return _handModelMatch

func getCoinFaceModel() -> CoinFaceModel:
	return _coinFaceModelMatch
