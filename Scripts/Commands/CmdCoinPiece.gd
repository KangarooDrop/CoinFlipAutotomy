extends Node

var _modelToNode : Dictionary[CoinPieceModel, CoinPieceNode] = {}

####################################################################################################

func _onCoinPieceModelChange(newCoinPieceModel : CoinPieceModel, oldCoinPieceModel : CoinPieceModel, coinPieceNode : CoinPieceNode) -> void:
	_modelToNode.erase(oldCoinPieceModel)
	_modelToNode[newCoinPieceModel] = coinPieceNode

####################################################################################################

func getModelToNode(coinPieceModel : CoinPieceModel) -> CoinPieceNode:
	if not _modelToNode.has(coinPieceModel):
		return null
	return _modelToNode[coinPieceModel]

func createCoinPieceNode(coinPieceModel : CoinPieceModel, pieceHolder : Node) -> CoinPieceNode:
	var coinPieceNode : CoinPieceNode = Preloader.create(Preloader.coinPieceNode)
	pieceHolder.add_child(coinPieceNode)
	coinPieceNode.setModel(coinPieceModel)
	coinPieceNode.model_changed.connect(_onCoinPieceModelChange.bind(coinPieceNode))
	return coinPieceNode

func freeCoinPieceNode(coinPieceNode : CoinPieceNode) -> void:
	var model : CoinPieceModel = coinPieceNode.getModel()
	if _modelToNode.has(model):
		_modelToNode.erase(model)
	coinPieceNode.name += "_OLD"
	coinPieceNode.get_parent().remove_child(coinPieceNode)
	#coinPieceNode.setModel(null)
	coinPieceNode.queue_free()

####################################################################################################
