extends Node

class_name VenderItemHolder

var itemNodes : Array = []
var itemModelToNode : Dictionary = {}
var nodeToItemModel : Dictionary = {}

var offsetPerItem : int = 32
const offsetBuffer : int = 0

@export var itemType : VenderItem.ITEM_TYPE = VenderItem.ITEM_TYPE.RING
@export var numItems : int = 3

@onready var itemHBox : HBoxContainer = get_node("%ItemHBox")
@onready var backgroundNPR : NinePatchRect = get_node("%BackgroundNPR")

signal item_node_pressed(holderSource : VenderItemHolder, venderItemNode : VenderItem)

func _ready() -> void:
	offsetPerItem += itemHBox.get_theme_constant("separation")
	backgroundNPR.size.x = offsetBuffer*2.0
	initItems()

func initItems() -> void:
	for i in range(numItems):
		addItem()

func addItem(itemModel : ItemModel = null) -> void:
	var venderItemNode : VenderItem = Preloader.venderItemNode.instantiate()
	venderItemNode.pressed.connect(self.onItemNodePressed.bind(venderItemNode))
	itemHBox.add_child(venderItemNode)
	itemNodes.append(venderItemNode)
	_refreshItemNode(venderItemNode, itemModel)
	updateBackgroundSize()

func onItemNodePressed(venderItemNode : VenderItem) -> void:
	item_node_pressed.emit(self, venderItemNode)

func updateBackgroundSize() -> void:
	var endWidth : float = offsetPerItem * itemNodes.size() + offsetBuffer*2.0
	var d : float = endWidth - backgroundNPR.size.x
	backgroundNPR.size.x += d
	backgroundNPR.position.x -= d/2.0
	#print(name, " ", itemNodes.size(), " ", d)

func getRandomItem() -> ItemModel:
	var itemModel : ItemModel = null
	if itemType == VenderItem.ITEM_TYPE.RING:
		itemModel = ModelDB.getRing(ModelDB.getRandomRingScript())
	elif itemType == VenderItem.ITEM_TYPE.COIN_PIECE_CORE:
		itemModel = ModelDB.getCoinPiece(ModelDB.getRandomCoinPieceCoreScript())
	elif itemType == VenderItem.ITEM_TYPE.COIN_PIECE_EXTERIOR:
		itemModel = ModelDB.getCoinPiece(ModelDB.getRandomCoinPieceExteriorScript())
	return itemModel

func removeItemModel(itemModel : ItemModel) -> bool:
	if not itemModelToNode.has(itemModel):
		return false
	itemModelToNode[itemModel].hide()
	return true

func _refreshItemNode(venderItemNode : VenderItem, itemModel : ItemModel = null) -> void:
	if not venderItemNode.visible:
		venderItemNode.show()
	if itemModel == null:
		itemModel = getRandomItem()
	itemModelToNode[itemModel] = venderItemNode
	nodeToItemModel[venderItemNode] = itemModel
	venderItemNode.setItem(itemModel)

func refreshAllItems() -> void:
	for venderItemNode : VenderItem in itemNodes:
		_refreshItemNode(venderItemNode)
