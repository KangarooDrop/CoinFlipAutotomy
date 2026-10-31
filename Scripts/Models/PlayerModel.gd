extends Serializable

class_name PlayerModel

const IS_HUMAN_KEY : String = "is_human"
const IS_CONTROLLED : String = "is_controlled"
const HAND_ORIGINAL_KEY : String = "hand_original"
const COIN_FACE_ORIGINAL_KEY : String = "coin_face_original"
const HAND_MATCH_KEY : String = "hand_match"
const COIN_FACE_MATCH_KEY : String = "coin_face_match"

var isHuman : bool = false
var isControlledCPU : bool = false
var _handModelOriginal : HandModel = null
var _coinFaceModelOriginal : CoinFaceModel = null

var _handModelMatch : HandModel = null
var _coinFaceModelMatch : CoinFaceModel = null

func setHandModel(handModel : HandModel) -> PlayerModel:
	_handModelOriginal = handModel
	_handModelOriginal.setPlayerModel(self)
	return self

func setCoinFaceModel(coinFaceModel : CoinFaceModel) -> PlayerModel:
	_coinFaceModelOriginal = coinFaceModel
	_coinFaceModelOriginal.setPlayerModel(self)
	return self

func resetMatchCoinFaceModel() -> void:
	_coinFaceModelMatch = _coinFaceModelOriginal.clone()
	_coinFaceModelMatch.setPlayerModel(self)

func resetMatchHandModel() -> void:
	_handModelMatch = _handModelOriginal.clone()
	_handModelMatch.setPlayerModel(self)

func getDemonScript() -> Script:
	return _handModelOriginal.getDemonScript()

func getOriginalHandModel() -> HandModel:
	return _handModelOriginal

func getOriginalCoinFaceModel() -> CoinFaceModel:
	return _coinFaceModelOriginal

func getHandModel() -> HandModel:
	return _handModelMatch

func getCoinFaceModel() -> CoinFaceModel:
	return _coinFaceModelMatch

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn[IS_HUMAN_KEY] = isHuman
	rtn[IS_CONTROLLED] = isControlledCPU
	rtn[HAND_ORIGINAL_KEY] = _handModelOriginal.serialize()
	rtn[COIN_FACE_ORIGINAL_KEY] = _coinFaceModelOriginal.serialize()
	
	if _handModelMatch != null:
		rtn[HAND_MATCH_KEY] = _handModelMatch.serialize()
	else:
		rtn[HAND_MATCH_KEY] = null
	if _coinFaceModelMatch != null:
		rtn[COIN_FACE_MATCH_KEY] = _coinFaceModelMatch.serialize()
	else:
		rtn[COIN_FACE_MATCH_KEY] = null
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	super.deserialize(data)
	isHuman = data[IS_HUMAN_KEY]
	isControlledCPU = data[IS_CONTROLLED]
	if _handModelOriginal == null:
		setHandModel(HandModel.new(data[HAND_ORIGINAL_KEY]))
	else:
		_handModelOriginal.deserialize(data[HAND_ORIGINAL_KEY])
		_handModelOriginal.setPlayerModel(self)
	if _coinFaceModelOriginal == null:
		setCoinFaceModel(CoinFaceModel.new(data[COIN_FACE_ORIGINAL_KEY]))
	else:
		_coinFaceModelOriginal.deserialize(data[COIN_FACE_ORIGINAL_KEY])
		_coinFaceModelOriginal.setPlayerModel(self)
	
	if data[HAND_MATCH_KEY] != null:
		if _handModelMatch == null:
			_handModelMatch = HandModel.new(data[HAND_MATCH_KEY])
		else:
			_handModelMatch.deserialize(data[HAND_MATCH_KEY])
		_handModelMatch.setPlayerModel(self)
	else:
		_handModelMatch = null
	if data[COIN_FACE_MATCH_KEY] != null:
		if _coinFaceModelMatch == null:
			_coinFaceModelMatch = CoinFaceModel.new(data[COIN_FACE_MATCH_KEY])
		else:
			_coinFaceModelMatch.deserialize(data[COIN_FACE_MATCH_KEY])
		_coinFaceModelMatch.setPlayerModel(self)
	else:
		_coinFaceModelMatch = null
	return self
