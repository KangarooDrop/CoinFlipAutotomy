extends Node2D

class_name CoinFaceNode

var _coinFaceModel : CoinFaceModel = null

var _socketIndexToNodes : Dictionary[Entities.CoinPieceSocketIndex, CoinPieceNode] = {}
var _modelToNode : Dictionary[CoinPieceModel, CoinPieceNode] = {}

@onready var pieceHolder : Node2D = get_node("%PieceHolder")

const LOCK_IN_MAX_TIME : float = 0.5
const LOCK_IN_WAIT : float = 0.02
const LOCK_IN_OFFSET : float = 56.0

####################################################################################################

func _init() -> void:
	_initSocketDict()

func _initSocketDict() -> void:
	for socketIndex : Entities.CoinPieceSocketIndex in Entities.getAllNonNone(Entities.CoinPieceSocketIndex):
		_socketIndexToNodes[socketIndex] = null

func _attachModel() -> void:
	_coinFaceModel.coin_piece_added.connect(onCoinPieceModelAdded)
	_coinFaceModel.coin_piece_removed.connect(onCoinPieceModelRemoved)
	_coinFaceModel.coin_piece_replaced.connect(onCoinPieceModelReplaced)

func _unattachModel() -> void:
	_coinFaceModel.coin_piece_added.disconnect(onCoinPieceModelAdded)
	_coinFaceModel.coin_piece_removed.disconnect(onCoinPieceModelRemoved)
	_coinFaceModel.coin_piece_replaced.disconnect(onCoinPieceModelReplaced)

func clear() -> void:
	if _coinFaceModel == null:
		return
	_unattachModel()
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToNodes.keys():
		var coinPieceNode : CoinPieceNode = onCoinPieceModelRemoved(socketIndex)
		if coinPieceNode != null:
			CmdCoinPiece.freeCoinPieceNode(coinPieceNode)
	_coinFaceModel = null
	_socketIndexToNodes.clear()
	_initSocketDict()
	_modelToNode.clear()

####################################################################################################

func setModel(newCoinFaceModel : CoinFaceModel) -> void:
	clear()
	_coinFaceModel = newCoinFaceModel
	_attachModel()
	
	for socketIndex : Entities.CoinPieceSocketIndex in _coinFaceModel.getUsedSocketIndices():
		var coinPiece : CoinPieceModel = _coinFaceModel.getCoinPieceAtSocket(socketIndex)
		if coinPiece != null:
			onCoinPieceModelAdded(socketIndex, coinPiece)

func playLockInAnim(delay : float = 0.0) -> void:
	z_index += 1
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToNodes.keys():
		if socketIndex == Entities.CoinPieceSocketIndex.CORE:
			continue
		if _socketIndexToNodes[socketIndex] == null:
			continue
		var coinPieceNode : CoinPieceNode = _socketIndexToNodes[socketIndex]
		coinPieceNode.z_index = -1
		coinPieceNode.hide()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	var lastTween : Tween = null
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToNodes.keys():
		if socketIndex == Entities.CoinPieceSocketIndex.CORE:
			continue
		if _socketIndexToNodes[socketIndex] == null:
			continue
		var coinPieceNode : CoinPieceNode = _socketIndexToNodes[socketIndex]
		coinPieceNode.show()
		var endPos : Vector2 = Util.getSocketIndexToCoinPieceRotData(socketIndex).getOffset()
		lastTween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_QUAD)
		lastTween.tween_property(coinPieceNode, "position", endPos.normalized() * LOCK_IN_OFFSET, LOCK_IN_MAX_TIME/2.0)
		lastTween.tween_callback(func(): coinPieceNode.z_index = 0)
		lastTween.set_trans(Tween.TRANS_QUINT)
		lastTween.tween_property(coinPieceNode, "position", endPos, LOCK_IN_MAX_TIME/2.0)
		await get_tree().create_timer(LOCK_IN_WAIT).timeout
	if lastTween != null:
		await lastTween.finished
	z_index -= 1

func getModel() -> CoinFaceModel:
	return _coinFaceModel

func onCoinPieceModelAdded(socketIndex : Entities.CoinPieceSocketIndex, coinPieceModel : CoinPieceModel) -> CoinPieceNode:
	if not _socketIndexToNodes.has(socketIndex):
		push_error("ERROR: Invalid index given to onCoinPieceModelAdded")
		return null
	var coinPieceNode : CoinPieceNode = CmdCoinPiece.getModelToNode(coinPieceModel)
	if coinPieceNode == null:
		coinPieceNode = CmdCoinPiece.createCoinPieceNode(coinPieceModel, pieceHolder)
	return onCoinPieceNodeAdded(socketIndex, coinPieceNode)

func onCoinPieceNodeAdded(socketIndex : Entities.CoinPieceSocketIndex, coinPieceNode : CoinPieceNode) -> CoinPieceNode:
	if not _socketIndexToNodes.has(socketIndex):
		push_error("ERROR: Invalid index given to onCoinPieceNodeAdded")
		return null
	
	var rtn : CoinPieceNode = onCoinPieceModelRemoved(socketIndex)
	
	var parentNode : Node = coinPieceNode.get_parent()
	if is_instance_valid(parentNode) and parentNode != pieceHolder:
		parentNode.remove_child(coinPieceNode)
	if parentNode != pieceHolder:
		pieceHolder.add_child(coinPieceNode)
	var coinPieceModel : CoinPieceModel = coinPieceNode.getModel()
	var rotData : CoinPieceRotData = Util.getSocketIndexToCoinPieceRotData(socketIndex)
	coinPieceNode.position = rotData.getOffset()
	coinPieceNode.setRotationData(rotData)
	_socketIndexToNodes[socketIndex] = coinPieceNode
	_modelToNode[coinPieceModel] = coinPieceNode
	return rtn

func onCoinPieceModelRemoved(socketIndex : Entities.CoinPieceSocketIndex, coinPieceModel : CoinPieceModel = null) -> CoinPieceNode:
	if not _socketIndexToNodes.has(socketIndex):
		push_error("ERROR: Invalid index given to onCoinPieceModelRemoved")
		return null
	var coinPieceNode : CoinPieceNode = _socketIndexToNodes[socketIndex]
	if coinPieceNode == null:
		return null
	if coinPieceModel == null:
		coinPieceModel = coinPieceNode.getModel()
	
	_modelToNode.erase(coinPieceModel)
	_socketIndexToNodes[socketIndex] = null
	return coinPieceNode

func onCoinPieceModelReplaced(socketIndex : Entities.CoinPieceSocketIndex, newCoinPieceModel : CoinPieceModel, oldCoinPieceModel : CoinPieceModel) -> bool:
	if not _socketIndexToNodes.has(socketIndex):
		push_error("ERROR: Invalid index given to onCoinPieceModelReplaced")
		return false
	var coinPieceNode : CoinPieceNode = _socketIndexToNodes[socketIndex]
	if coinPieceNode == null:
		push_error("ERROR: Index given to onCoinPieceModelReplaced was empty")
		return false
	
	_modelToNode.erase(oldCoinPieceModel)
	_modelToNode[newCoinPieceModel] = coinPieceNode
	coinPieceNode.setModel(newCoinPieceModel)
	return true

func getAllCoinPieceNodes() -> Array[CoinPieceNode]:
	return _modelToNode.values()

func getCoinPieceNodeToSocketIndex(coinPieceNode : CoinPieceNode) -> Entities.CoinPieceSocketIndex:
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToNodes.keys():
		if _socketIndexToNodes[socketIndex] == coinPieceNode:
			return socketIndex
	return Entities.CoinPieceSocketIndex.NONE
