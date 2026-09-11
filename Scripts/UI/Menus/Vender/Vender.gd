extends Control

class_name Vender

const COST_REFRESH : int = 1
const COST_RING : int = 1
const COST_COIN_PIECE_EXTERIOR : int = 1
const COST_COIN_PIECE_CORE : int = 1
const SELL_MULTIPLIER : float = 1.0

const QUICK_BUY_MAX_TIME : float = 0.125
const COIN_PIECE_MAX_DIST : float = 32.0 * 4.0
const RING_MAX_DIST : float = 32.0 * 4.0

var _itemNodeButtonDown = null
var _itemNodeHeld = null
var _wasVenderItem : bool = false
var _itemCoinPieceOriginalSocketIndex : Entities.CoinPieceSocketIndex = Entities.CoinPieceSocketIndex.NONE
var _itemRingOriginalIndex : int = -1
var _itemNodeOriginalPosition : Vector2 = Vector2.ZERO
var _quickBuyTimer : float = QUICK_BUY_MAX_TIME

@onready var gearHolder : GearHolder = get_node("%GearHolder")
@onready var handNode : HandNode = gearHolder.handNode
@onready var coinFaceNode : CoinFaceNode = gearHolder.coinFaceNode

@onready var coinPieceHolder : VenderItemHolder = get_node("%CoinPieceHolder")
@onready var ringHolder : VenderItemHolder = get_node("%RingHolder")
@onready var coreHolder : VenderItemHolder = get_node("%CoreHolder")
@onready var itemHolders : Array[VenderItemHolder] = [coinPieceHolder, ringHolder, coreHolder]

@onready var skipButton : ButtonNine = get_node("%SkipButton")
@onready var nextButton : ButtonNine = get_node("%NextButton")

####################################################################################################

func _ready() -> void:
	var playerModel : PlayerModel = RunManager.getUserPlayerModel()
	handNode.setHandModel(playerModel.getOriginalHandModel())
	coinFaceNode.setModel(playerModel.getOriginalCoinFaceModel())

func _process(delta: float) -> void:
	if _quickBuyTimer < QUICK_BUY_MAX_TIME:
		_quickBuyTimer += delta
	if _itemNodeHeld != null:
		var mousePosition : Vector2 = get_global_mouse_position()
		_itemNodeHeld.global_position = mousePosition
		
		if _itemNodeHeld is CoinPieceNode:
			if _itemNodeHeld.getModel().coinPieceType != Entities.CoinPieceType.CORE:
				var socketIndex : Entities.CoinPieceSocketIndex = getNodeToSocketIndex(_itemNodeHeld)
				var socketIndexVisual : Entities.CoinPieceSocketIndex = socketIndex if socketIndex != Entities.CoinPieceSocketIndex.NONE else Entities.CoinPieceSocketIndex.EXT_UP
				var coinPieceRotData : CoinPieceRotData = Util.getSocketIndexToCoinPieceRotData(socketIndexVisual)
				_itemNodeHeld.setRotationData(coinPieceRotData)
				
				var coinFaceModel : CoinFaceModel = coinFaceNode.getModel()
				var shouldRotate : bool = true
				if socketIndex == Entities.CoinPieceSocketIndex.NONE:
					shouldRotate = false
				if socketIndex == _itemCoinPieceOriginalSocketIndex and not _wasVenderItem:
					shouldRotate = false
				if coinFaceModel.getCoinPieceAtSocket(socketIndex) == null:
					shouldRotate = false
				if shouldRotate:
					for i in range(8):
						var dir : int = ((i%2)*2-1)
						var offset : int = (i/2+1) * dir
						var nextSocketIndex : Entities.CoinPieceSocketIndex = Entities.CoinPieceSocketScript.getRotated(socketIndex, offset)
						if coinFaceModel.getCoinPieceAtSocket(nextSocketIndex) == null:
							for j in range(abs(offset)):
								var fromSocket : Entities.CoinPieceSocketIndex = Entities.CoinPieceSocketScript.getRotated(nextSocketIndex, -(j+1)*dir)
								var toSocket : Entities.CoinPieceSocketIndex = Entities.CoinPieceSocketScript.getRotated(nextSocketIndex, -j*dir)
								CmdCoinPiece.freeCoinPieceNode(coinFaceNode.getCoinPieceNodeAtSocketIndex(fromSocket))
								var coinPieceModelToMove : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(fromSocket)
								coinFaceModel.removeCoinPieceFromSocket(fromSocket)
								coinFaceModel.insertCoinPiece(toSocket, coinPieceModelToMove)
							break
				if not _wasVenderItem:
					_itemCoinPieceOriginalSocketIndex = socketIndex
		elif _itemNodeHeld is RingNode:
			var index : int = getNodeToRingIndex(_itemNodeHeld)
			var ringRotation : float = 0.0
			if index != -1:
				ringRotation = handNode.getModel().getRotData()[index].getRotation(handNode.flipH)
			_itemNodeHeld.sprite.rotation = ringRotation
			
			var handModel : HandModel = handNode.getModel()
			var shouldRotate : bool = true
			if index == -1:
				shouldRotate = false
			if index == _itemRingOriginalIndex and not _wasVenderItem:
				shouldRotate = false
			if shouldRotate and handModel.getFinger(index).getRingModel() == null:
				shouldRotate = false
			if shouldRotate:
				for i in range(handModel.getTotalNumFingers()*2):
					var dir : int = ((i%2)*2-1)
					var offset : int = (i/2+1) * dir
					var nextIndex : int = index + offset
					if nextIndex < 0 or nextIndex >= handNode.getTotalNumFingers():
						continue
					if handModel.getFinger(nextIndex).getRingModel() == null:
						for j in range(abs(offset)):
							var fromIndex : int = nextIndex - (j+1)*dir
							var toIndex : int = nextIndex - j*dir
							CmdFinger.freeRingNode(handNode.getRingNode(fromIndex))
							var ringModelToMove : RingModel = handModel.getFinger(fromIndex).getRingModel()
							handModel.getFinger(fromIndex).setRingModel(null)
							handModel.getFinger(toIndex).setRingModel(ringModelToMove)
						break
			if not _wasVenderItem:
				_itemRingOriginalIndex = index

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				var itemNodes : Array = []
				for venderItemHolder : VenderItemHolder in itemHolders:
					itemNodes += venderItemHolder.getItemNodes()
				for itemNode in coinFaceNode.getAllCoinPieceNodes() + handNode.getAllRingNodes():
					itemNodes.append(itemNode)
				for itemNode in itemNodes:
					if itemNode.tooltipViewer.isMouseHovering():
						_on_itemNodeButtonDown(itemNode)
			else:
				_onItemNodeButtonUp()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			_reset_itemNodeHeld()

####################################################################################################

func getNodeToSocketIndex(coinPieceNode : CoinPieceNode) -> Entities.CoinPieceSocketIndex:
	var isCore : bool = coinPieceNode.getModel().coinPieceType == Entities.CoinPieceType.CORE
	var diff : Vector2 = coinPieceNode.global_position - coinFaceNode.global_position
	var distMult : float = 0.5 if isCore else 1.0
	if diff.length() > COIN_PIECE_MAX_DIST * distMult:
		return Entities.CoinPieceSocketIndex.NONE
	if isCore:
		return Entities.CoinPieceSocketIndex.CORE
	var angle : float = ((coinPieceNode.global_position - coinFaceNode.global_position) as Vector2).angle() + PI/2.0
	if angle < 0.0:
		angle += 2.0 * PI
	return int((angle * 8.0) / (2.0 * PI) + 0.5) % 8 + 1 as Entities.CoinPieceSocketIndex

func getNodeToRingIndex(ringNode : RingNode) -> int:
	var nearestDist : float = RING_MAX_DIST
	var nearestIndex : int = -1
	var handModel : HandModel = handNode.getModel()
	for i in range(handModel.getTotalNumFingers()):
		var ringRotData : RingRotData = handModel.getRotData()[i]
		var diff : Vector2 = handNode.global_position + Vector2(ringRotData.getOffset(handNode.flipH)) - ringNode.global_position
		var dist : float = diff.length()
		if dist < nearestDist:
			nearestIndex = i
			nearestDist = dist
	return nearestIndex

func _isVenderItem(itemNode) -> bool:
	return itemNode.getModel().getPlayerModel() == null

func _canAfford(amount : int) -> bool:
	if amount == -1:
		return false
	return RunManager.getNumTokens() >= amount

func _getNodeToCost(node : Node) -> int:
	if node is CoinPieceNode:
		if node.getModel().coinPieceType == Entities.CoinPieceType.CORE:
			return COST_COIN_PIECE_CORE
		else:
			return COST_COIN_PIECE_EXTERIOR
	elif node is RingNode:
		return COST_RING
	else:
		return -1

func _getSellVal(node : Node) -> int:
	return ceil(_getNodeToCost(node) * SELL_MULTIPLIER)

####################################################################################################

func _on_itemNodeButtonDown(itemNode) -> void:
	if _itemNodeHeld == null:
		_itemNodeButtonDown = itemNode
		itemNode.tooltipViewer.mouse_exited.connect(_onItemNodeSelected)
	else:
		_onItemNodeDeselected()

func _onItemNodeButtonUp() -> void:
	if _itemNodeHeld == null:
		_quickBuyTimer = 0.0
		_onItemNodeSelected()
	elif _quickBuyTimer < QUICK_BUY_MAX_TIME:
		if _wasVenderItem:
			_onQuickBuy()
		else:
			_onQuickSell()
	else:
		_onItemNodeDeselected()

func _onItemNodeSelected() -> void:
	if _itemNodeButtonDown == null:
		return
	#Is shop item (not owned by player)
	if _isVenderItem(_itemNodeButtonDown):
		var cost : int = _getNodeToCost(_itemNodeButtonDown)
		if not _canAfford(cost):
			_itemNodeButtonDown.tooltipViewer.mouse_exited.disconnect(_onItemNodeSelected)
			_itemNodeButtonDown = null
			return
	
	_itemNodeHeld = _itemNodeButtonDown
	_itemNodeHeld.tooltipViewer.disable()
	_itemNodeOriginalPosition = _itemNodeHeld.position
	_wasVenderItem = _isVenderItem(_itemNodeHeld)
	if _itemNodeHeld is CoinPieceNode:
		if _wasVenderItem:
			_itemCoinPieceOriginalSocketIndex = Entities.CoinPieceSocketIndex.CORE if _itemNodeHeld.getModel().coinPieceType == Entities.CoinPieceType.CORE else Entities.CoinPieceSocketIndex.EXT_UP
		else:
			_itemCoinPieceOriginalSocketIndex = _itemNodeHeld.getModel().getSocketIndex()
			coinFaceNode.getModel().removeCoinPieceFromSocket(_itemCoinPieceOriginalSocketIndex)
	elif _itemNodeHeld is RingNode:
		if _wasVenderItem:
			_itemRingOriginalIndex = -1
		else:
			_itemRingOriginalIndex = handNode.getModel().getRingIndex(_itemNodeHeld.getModel())
			handNode.getModel().getFinger(_itemRingOriginalIndex).setRingModel(null)
	
	_itemNodeButtonDown.tooltipViewer.mouse_exited.disconnect(_onItemNodeSelected)
	_itemNodeButtonDown = null

func _onItemNodeDeselected() -> void:
	if _itemNodeHeld is CoinPieceNode:
		var socketIndex : Entities.CoinPieceSocketIndex = getNodeToSocketIndex(_itemNodeHeld)
		if socketIndex == Entities.CoinPieceSocketIndex.NONE:
			_reset_itemNodeHeld()
		elif coinFaceNode.getModel().getCoinPieceAtSocket(socketIndex) != null:
			_reset_itemNodeHeld()
		else:
			if _wasVenderItem:
				_onBuyCoinPiece(socketIndex)
			else:
				CmdCoinPiece.freeCoinPieceNode(_itemNodeHeld)
				coinFaceNode.getModel().insertCoinPiece(socketIndex, _itemNodeHeld.getModel())
				_reinit_itemNodeHeld()
	elif _itemNodeHeld is RingNode:
		var index : int = getNodeToRingIndex(_itemNodeHeld)
		if index == -1:
			_reset_itemNodeHeld()
		elif handNode.getModel().getFinger(index).getRingModel() != null:
			_reset_itemNodeHeld()
		else:
			if _wasVenderItem:
				_onBuyRing(index)
			else:
				CmdFinger.freeRingNode(_itemNodeHeld)
				handNode.getModel().getFinger(index).setRingModel(_itemNodeHeld.getModel())
				_reinit_itemNodeHeld()

func _onQuickBuy() -> void:
	var cost : int = _getNodeToCost(_itemNodeHeld)
	if _canAfford(cost):
		var isCoinPiece : bool = _itemNodeHeld is CoinPieceNode
		var isRing : bool = _itemNodeHeld is RingNode
		if isRing:
			var nextIndex : int = handNode.getModel().getNextRingIndex()
			if nextIndex != -1:
				_onBuyRing(nextIndex)
		elif isCoinPiece:
			var nextIndex : Entities.CoinPieceSocketIndex = coinFaceNode.getModel().getNextIndex(_itemNodeHeld.getModel().coinPieceType)
			if nextIndex != Entities.CoinPieceSocketIndex.NONE:
				_onBuyCoinPiece(nextIndex)
	else:
		_reset_itemNodeHeld()

func _onBuyCoinPiece(socketIndex : Entities.CoinPieceSocketIndex) -> void:
	var cost : int = _getNodeToCost(_itemNodeHeld)
	for itemHolder : VenderItemHolder in itemHolders:
		if itemHolder.getItemNodes().has(_itemNodeHeld):
			itemHolder.eraseItemModel(_itemNodeHeld.getModel())
	CmdCoinPiece.freeCoinPieceNode(_itemNodeHeld)
	coinFaceNode.getModel().insertCoinPiece(socketIndex, _itemNodeHeld.getModel())
	RunManager.addNumTokens(-cost)
	_reinit_itemNodeHeld()

func _onBuyRing(index : int) -> void:
	var cost : int = _getNodeToCost(_itemNodeHeld)
	for itemHolder : VenderItemHolder in itemHolders:
		if itemHolder.getItemNodes().has(_itemNodeHeld):
			itemHolder.eraseItemModel(_itemNodeHeld.getModel())
	CmdFinger.freeRingNode(_itemNodeHeld)
	handNode.getModel().getFinger(index).setRingModel(_itemNodeHeld.getModel())
	RunManager.addNumTokens(-cost)
	_reinit_itemNodeHeld()

func _onQuickSell() -> void:
	var sellVal : int = _getSellVal(_itemNodeHeld)
	if _itemNodeHeld is RingNode:
		CmdFinger.freeRingNode(_itemNodeHeld)
		handNode.getModel().eraseRing(_itemNodeHeld.getModel())
	elif _itemNodeHeld is CoinPieceNode:
		CmdCoinPiece.freeCoinPieceNode(_itemNodeHeld)
		coinFaceNode.getModel().eraseCoinPiece(_itemNodeHeld.getModel())
	RunManager.addNumTokens(sellVal)
	_reinit_itemNodeHeld()

func _reset_itemNodeHeld() -> void:
	if _itemNodeHeld is CoinPieceNode:
		_resetCoinPieceHeld()
	elif _itemNodeHeld is RingNode:
		_resetRingHeld()

func _resetCoinPieceHeld() -> void:
	var coinPieceRotData : CoinPieceRotData = Util.getSocketIndexToCoinPieceRotData(_itemCoinPieceOriginalSocketIndex)
	_itemNodeHeld.setRotationData(coinPieceRotData)
	_itemNodeHeld.position = _itemNodeOriginalPosition
	if not _wasVenderItem:
		CmdCoinPiece.freeCoinPieceNode(_itemNodeHeld)
		coinFaceNode.getModel().insertCoinPiece(_itemCoinPieceOriginalSocketIndex, _itemNodeHeld.getModel())
	_reinit_itemNodeHeld()

func _resetRingHeld() -> void:
	if _itemRingOriginalIndex == -1:
		_itemNodeHeld.sprite.rotation = 0.0
	else:
		_itemNodeHeld.sprite.rotation = handNode.getModel().getRotData()[_itemRingOriginalIndex].getRotation(handNode.flipH)
	_itemNodeHeld.position = _itemNodeOriginalPosition
	if not _wasVenderItem:
		CmdFinger.freeRingNode(_itemNodeHeld)
		handNode.getModel().getFinger(_itemRingOriginalIndex).setRingModel(_itemNodeHeld.getModel())
	_reinit_itemNodeHeld()

func _reinit_itemNodeHeld() -> void:
	_itemNodeHeld.tooltipViewer.enable()
	_itemNodeHeld = null
	_itemCoinPieceOriginalSocketIndex = Entities.CoinPieceSocketIndex.NONE

####################################################################################################

func onUserCoinPieceNodePressed(coinPieceNode : CoinPieceNode) -> void:
	var sellVal : int = _getSellVal(coinPieceNode)
	coinFaceNode.getModel().eraseCoinPiece(coinPieceNode.getModel())
	CmdCoinPiece.freeCoinPieceNode(coinPieceNode)
	RunManager.addNumTokens(sellVal)

func onUserRingPressed(ringNode : RingNode) -> void:
	var sellVal : int = _getSellVal(ringNode)
	handNode.getModel().eraseRing(ringNode.getModel())
	CmdFinger.freeRingNode(ringNode)
	RunManager.addNumTokens(sellVal)

func onRefreshPressed() -> void:
	if not _canAfford(COST_REFRESH):
		return
	for holder : VenderItemHolder in itemHolders:
		holder.refreshAllItems()
	RunManager.addNumTokens(-COST_REFRESH)

func onNextPressed() -> void:
	RunManager.onVenderExited()
