extends RefCounted

class_name PlayerModel

var isHuman : bool = false
var isControlledCPU : bool = false
var _demonScript : Script = null
var _handModelOriginal : HandModel = null
var _coinFaceModelOriginal : CoinFaceModel = null

var _handModelMatch : HandModel = null
var _coinFaceModelMatch : CoinFaceModel = null

func _init(demonScript : Script, handModel : HandModel, coinFaceModel : CoinFaceModel) -> void:
	_demonScript = demonScript
	_handModelOriginal = handModel
	_handModelOriginal.setPlayerModel(self)
	_coinFaceModelOriginal = coinFaceModel
	_coinFaceModelOriginal.setPlayerModel(self)

func resetMatchCoinFaceModel() -> void:
	_coinFaceModelMatch = _coinFaceModelOriginal.clone()

func resetMatchHandModel() -> void:
	_handModelMatch = _handModelOriginal.clone()

func getDemonScript() -> Script:
	return _demonScript

func getOriginalHandModel() -> HandModel:
	return _handModelOriginal

func getOriginalCoinFaceModel() -> CoinFaceModel:
	return _coinFaceModelOriginal

func getHandModel() -> HandModel:
	return _handModelMatch

func getCoinFaceModel() -> CoinFaceModel:
	return _coinFaceModelMatch

func clone() -> PlayerModel:
	var playerModelClone : PlayerModel = PlayerModel.new(_demonScript, _handModelOriginal.clone(), _coinFaceModelOriginal.clone())
	playerModelClone._handModelOriginal.setPlayerModel(playerModelClone)
	playerModelClone._coinFaceModelOriginal.setPlayerModel(playerModelClone)
	playerModelClone._handModelMatch = _handModelMatch.clone()
	playerModelClone._coinFaceModelMatch = _coinFaceModelMatch.clone()
	playerModelClone._handModelMatch.setPlayerModel(playerModelClone)
	playerModelClone._coinFaceModelMatch.setPlayerModel(playerModelClone)
	playerModelClone.isHuman = isHuman
	playerModelClone.isControlledCPU = isControlledCPU
	return playerModelClone
