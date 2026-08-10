extends Node
class_name CmdCoinPiece

static func getModelToNode(coinPieceModel : CoinPieceModel) -> CoinPieceNode:
	var tree : SceneTree = Engine.get_main_loop() as SceneTree
	for coinPieceNode : CoinPieceNode in tree.get_nodes_in_group("CoinPieceNode"):
		if coinPieceNode.getModel() == coinPieceModel:
			print("Found Coin Piece Node that matches model.")
	return null

static func createCoinPieceNode(coinPieceModel : CoinPieceModel, pieceHolder : Node) -> CoinPieceNode:
	var coinPieceNode : CoinPieceNode = Preloader.create(Preloader.coinPieceNode)
	pieceHolder.add_child(coinPieceNode)
	coinPieceNode.setModel(coinPieceModel)
	return coinPieceNode

static func freeCoinPieceNode(coinPieceNode : CoinPieceNode) -> void:
	coinPieceNode.name += "_OLD"
	coinPieceNode.get_parent().remove_child(coinPieceNode)
	#coinPieceNode.setModel(null)
	coinPieceNode.queue_free()
