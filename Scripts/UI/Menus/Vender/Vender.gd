extends Node2D

class_name Vender

@onready var coinPieceHolder : VenderItemHolder = get_node("%CoinPieceHolder")
@onready var ringHolder : VenderItemHolder = get_node("%RingHolder")
@onready var coreHolder : VenderItemHolder = get_node("%CoreHolder")

@onready var skipButton : ButtonNine = get_node("%SkipButton")
@onready var nextButton : ButtonNine = get_node("%NextButton")

@onready var itemHolders : Array[VenderItemHolder] = [coinPieceHolder, ringHolder, coreHolder]

func _ready() -> void:
	var demon : DemonModel = ModelDB.getDemon(DemonGluttony)
	var handModel : HandModel = HandModel.new(demon)
	$HandNode.setHandModel(handModel)
	
	if get_tree().current_scene == self:
		position = Vector2(Util.screenWidth/2.0, Util.screenHeight/2.0)

func onItemNodePressed(holderSource : VenderItemHolder, venderItemNode : VenderItem) -> void:
	holderSource.removeItemModel(venderItemNode.itemModel)

func onRefreshPressed() -> void:
	for holder : VenderItemHolder in itemHolders:
		holder.refreshAllItems()
