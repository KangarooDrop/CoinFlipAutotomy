extends Node2D

class_name CoinNode

const FLIP_DURATION_SLOW : float = 0.5
const FLIP_DURATION_FAST : float = 0.1
const RAPID_FLIP_DURATION : float = 2.0

var _currentFaceModel : CoinFaceModel = null
var _coinFaceModelUser : CoinFaceModel = null
var _coinFaceModelOpponent : CoinFaceModel = null

var modelToNode : Dictionary = {}
var nodeToModel : Dictionary = {}

@onready var _coinFaceNodeUser : CoinFaceNode = get_node("%CoinFaceNodeUser")
@onready var _coinFaceNodeOpponent : CoinFaceNode = get_node("%CoinFaceNodeOpponent")

func _attachModel(coinFaceModel : CoinFaceModel, isUser : bool) -> void:
	pass

func _unattachModel(coinFaceModel : CoinFaceModel, isUser : bool) -> void:
	pass

func setCoinFaceModelUser(coinFaceModel : CoinFaceModel) -> void:
	if _coinFaceModelUser != null:
		_unattachModel(_coinFaceModelUser, true)
	_coinFaceModelUser = coinFaceModel
	_coinFaceNodeUser.setModel(coinFaceModel)
	modelToNode[coinFaceModel] = _coinFaceNodeUser
	nodeToModel[_coinFaceNodeUser] = coinFaceModel
	_attachModel(_coinFaceModelUser, true)

func setCoinFaceModelOpponent(coinFaceModel : CoinFaceModel) -> void:
	if _coinFaceModelOpponent != null:
		_unattachModel(_coinFaceModelOpponent, false)
	_coinFaceModelOpponent = coinFaceModel
	_coinFaceNodeOpponent.setModel(coinFaceModel)
	modelToNode[coinFaceModel] = _coinFaceNodeOpponent
	nodeToModel[_coinFaceNodeOpponent] = coinFaceModel
	_attachModel(_coinFaceModelOpponent, false)

func getObverseModel() -> CoinFaceModel:
	return _currentFaceModel
func getReverseModel() -> CoinFaceModel:
	return getOtherFaceModel(getObverseModel())

func setObverseModel(coinFaceModel : CoinFaceModel) -> void:
	if coinFaceModel == _currentFaceModel:
		return
	_currentFaceModel = coinFaceModel
	var newObverseNode : CoinFaceNode = getCoinFaceModelToNode(coinFaceModel)
	newObverseNode.show()
	newObverseNode.scale = Vector2(1.0, 1.0)
	var newReverseNode : CoinFaceNode = getCoinFaceModelToNode(getOtherFaceModel(coinFaceModel))
	newReverseNode.hide()
	newReverseNode.scale = Vector2(0.0, 1.0)

func getOtherFaceModel(coinFaceModel : CoinFaceModel) -> CoinFaceModel:
	if coinFaceModel == _coinFaceModelUser:
		return _coinFaceModelOpponent
	elif coinFaceModel == _coinFaceModelOpponent:
		return _coinFaceModelUser
	else:
		push_error("ERROR: Unkown Coin Face Model give to /getOtherFaceModel")
		return null

func getCoinFaceModelToNode(coinFaceModel : CoinFaceModel) -> CoinFaceNode:
	if not modelToNode.has(coinFaceModel):
		push_error("ERROR: Unkown Coin Face Model give to /getCoinFaceModelToNode")
		return null
	return modelToNode[coinFaceModel]

func getCoinFaceNodeToModel(coinFaceNode : CoinFaceNode) -> CoinFaceModel:
	if not nodeToModel.has(coinFaceNode):
		push_error("ERROR: Unkown Coin Face Model give to /getCoinFaceNodeToModel")
		return null
	return nodeToModel[coinFaceNode]

func flipToOther(duration : float = FLIP_DURATION_SLOW) -> Signal:
	var obverseNode : CoinFaceNode = getCoinFaceModelToNode(getObverseModel())
	var reverseNode : CoinFaceNode = getCoinFaceModelToNode(getReverseModel())
	_currentFaceModel = getReverseModel()
	
	var tween : Tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(obverseNode, "scale", Vector2(0.0, 1.0), duration/2.0)
	tween.tween_callback(obverseNode.hide)
	tween.tween_callback(reverseNode.show)
	tween.tween_property(reverseNode, "scale", Vector2(1.0, 1.0), duration/2.0)
	return tween.finished

func flipToSame(duration : float = FLIP_DURATION_SLOW) -> Signal:
	var obverseNode : CoinFaceNode = getCoinFaceModelToNode(getObverseModel())
	var tween : Tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(obverseNode, "scale", Vector2(0.0, 1.0), duration/2.0)
	tween.tween_property(obverseNode, "scale", Vector2(1.0, 1.0), duration/2.0)
	return tween.finished

var counter = 0
func rapidFlip(endCoinFaceModel : CoinFaceModel, duration : float = RAPID_FLIP_DURATION, easeInOutVal : float = 1.0, numFlipsMin : int = 10) -> void:
	counter += 1
	var obverseNode : CoinFaceNode = getCoinFaceModelToNode(getObverseModel())
	var reverseNode : CoinFaceNode = getCoinFaceModelToNode(getReverseModel())
	if obverseNode.getModel() != endCoinFaceModel and reverseNode.getModel() != endCoinFaceModel:
		push_error("ERROR: Invalid Coin Face Model given to /rapidFlip")
		return
	var flipDuration : float = 0.0
	for i in range(numFlipsMin):
		flipDuration = float(i+1)/numFlipsMin
		flipDuration = 2.0*(2.0 * easeInOutVal * flipDuration - flipDuration - easeInOutVal + 1.0)
		flipDuration *= duration/(numFlipsMin)
		await flipToOther(flipDuration)
		var tmp : CoinFaceNode = obverseNode
		obverseNode = reverseNode
		reverseNode = tmp
	if obverseNode.getModel() != endCoinFaceModel:
		flipToOther(flipDuration)

func flipToModel(coinFaceModel : CoinFaceModel, duration : float = FLIP_DURATION_SLOW) -> void:
	if coinFaceModel != _coinFaceModelUser and coinFaceModel != _coinFaceModelOpponent:
		push_error("ERROR: Unkown Coin Face Model give to /flipToModel")
		return
	if coinFaceModel == _currentFaceModel:
		await flipToSame(duration)
	else:
		await flipToOther(duration)

func _onFlipFinished() -> void:
	pass

func getAllCoinPieceNodes() -> Array[CoinPieceNode]:
	return _coinFaceNodeUser.getAllCoinPieceNodes() + _coinFaceNodeOpponent.getAllCoinPieceNodes()
