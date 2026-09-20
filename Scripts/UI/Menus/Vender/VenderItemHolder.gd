extends Node

class_name VenderItemHolder

const OFFSET_ITEM_SIZE : int = 32
const OFFSET_ITEM_BUFFER : int = 8
const OFFSET_BACKGROUND_BUFFER : int = 4

var itemNodes : Array = []
var itemModelToNode : Dictionary = {}
var nodeToItemModel : Dictionary = {}

@export var itemType : VenderItem.ITEM_TYPE = VenderItem.ITEM_TYPE.RING
@export var numItems : int = 3

@onready var itemHolder : Control = get_node("%ItemHolder")
@onready var backgroundNPR : NinePatchRect = get_node("%BackgroundNPR")

signal item_node_button_down(holderSource : VenderItemHolder, venderItemNode, buttonIndex : int)
signal item_node_button_up(holderSource : VenderItemHolder, venderItemNode, buttonIndex : int)

####################################################################################################

func _ready() -> void:
	backgroundNPR.size.x = OFFSET_BACKGROUND_BUFFER * 2.0
	resetItems()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		for venderItem in itemNodes:
			if not is_instance_valid(venderItem):
				continue
			if venderItem.tooltipViewer.isMouseHovering():
				if event.is_pressed():
					item_node_button_down.emit(self, venderItem, event.button_index)
				else:
					item_node_button_up.emit(self, venderItem, event.button_index)
				break

####################################################################################################

func getItemNodes() -> Array:
	var rtn : Array = []
	for itemNode in itemNodes:
		if itemNode != null:
			rtn.append(itemNode)
	return rtn

func resetItems() -> void:
	clear()
	for i in range(numItems):
		addItem(getRandomItem())
	updateItemNodePositions()
	updateBackgroundSize()

func clear() -> void:
	for i in range(itemNodes.size()):
		if is_instance_valid(itemNodes[i]):
			if itemNodes[i] is CoinPieceNode:
				CmdCoinPiece.freeCoinPieceNode(itemNodes[i])
			elif itemNodes[i] is RingNode:
				CmdFinger.freeRingNode(itemNodes[i])
			removeItemAtIndex(i)
	itemNodes.clear()

func addItem(itemModel : ItemModel = null) -> void:
	var itemNode : Node = null
	if itemModel is RingModel:
		itemNode = CmdFinger.createRingNode(itemModel, itemHolder)
	elif itemModel is CoinPieceModel:
		itemNode = CmdCoinPiece.createCoinPieceNode(itemModel, itemHolder)
	itemNodes.append(itemNode)
	itemModelToNode[itemModel] = itemNode
	nodeToItemModel[itemNode] = itemModel

func removeItemAtIndex(index : int) -> bool:
	if index < 0 or index >= itemNodes.size():
		return false
	if not is_instance_valid(itemNodes[index]):
		return false
	var itemNode = itemNodes[index]
	var itemModel : LocalizedModel = itemNode.getModel()
	nodeToItemModel.erase(itemNode)
	itemModelToNode.erase(itemModel)
	itemNodes[index] = null
	return true

func eraseItemModel(itemModel : ItemModel) -> bool:
	if not itemModelToNode.has(itemModel):
		return false
	var index : int = itemNodes.find(itemModelToNode[itemModel])
	if index == -1:
		return false
	return removeItemAtIndex(itemNodes.find(itemModelToNode[itemModel]))

func updateItemNodePositions() -> void:
	for i in range(numItems):
		var offset : float = 0.0
		if numItems > 1:
			offset = i - (numItems-1)/2.0
		offset *= (OFFSET_ITEM_SIZE + OFFSET_ITEM_BUFFER)
		itemNodes[i].position = Vector2(offset, 0.0)

func updateBackgroundSize() -> void:
	var endWidth : float = OFFSET_ITEM_SIZE * numItems + OFFSET_ITEM_BUFFER * (numItems-1) + OFFSET_BACKGROUND_BUFFER * 2.0
	backgroundNPR.size.x = endWidth
	backgroundNPR.position.x = -endWidth/2.0

func getRandomItem() -> ItemModel:
	var itemModel : ItemModel = null
	if itemType == VenderItem.ITEM_TYPE.RING:
		itemModel = ModelDB.getRing(ModelDB.getRandomRingScript())
	elif itemType == VenderItem.ITEM_TYPE.COIN_PIECE_CORE:
		itemModel = CoinPieceModel.new().setAbilityScript(ModelDB.getRandomAbilityCoreScript())
	elif itemType == VenderItem.ITEM_TYPE.COIN_PIECE_EXTERIOR:
		itemModel = CoinPieceModel.new().setAbilityScript(ModelDB.getRandomAbilityExteriorScript())
	return itemModel

func refreshAllItems() -> void:
	resetItems()
