extends Node2D

class_name CoinPieceNode

@onready var sprite : Sprite2D = get_node("%Sprite2D")
@onready var tooltipViewer : TooltipViewer = get_node("%TooltipViewer")

var _sealNode : SealNode = null

var _coinPieceModel : CoinPieceModel = null

signal model_changed(newCoinPieceModel : CoinPieceModel, oldCoinPieceModel : CoinPieceModel)

func _attachModel() -> void:
	_coinPieceModel.seal_added.connectSignal(_onSealAdded)
	_coinPieceModel.seal_removed.connectSignal(_onSealRemoved)
	_coinPieceModel.seal_replaced.connectSignal(_onSealReplaced)

func _unattachModel() -> void:
	_coinPieceModel.seal_added.disconnectSignal(_onSealAdded)
	_coinPieceModel.seal_removed.disconnectSignal(_onSealRemoved)
	_coinPieceModel.seal_replaced.disconnectSignal(_onSealReplaced)

func _onSealAdded(sealModel : SealModel) -> void:
	if _sealNode != null:
		push_error("ERROR: Attempting to add a SealNode to CoinPieceNode while it currently has one.")
		return
	_sealNode = Preloader.create(Preloader.sealNode)
	add_child(_sealNode)
	_sealNode.setModel(sealModel)
	if visible:
		#var popTween : Tween = get_tree().create_tween().bind_node(_sealNode)
		await get_tree().create_timer(1.0).timeout

func _onSealRemoved(_sealModel : SealModel) -> void:
	if _sealNode == null:
		push_error("ERROR: Attempting to remove Seal from CoinPieceNode while it currently does not have one.")
		return
	_sealNode.queue_free()
	_sealNode = null

func _onSealReplaced(newSealModel : SealModel, oldSealModel : SealModel) -> void:
	if _sealNode == null:
		push_error("ERROR: Attempting to replace Seal from CoinPieceNode while it currently does not have one.")
		return
	if _sealNode.getModel() != oldSealModel:
		push_error("ERROR: Attempting to replace incorrect Seal from CoinPieceNode.")
		return
	await _onSealRemoved(oldSealModel)
	await _onSealAdded(newSealModel)

func setModel(newCoinPieceModel : CoinPieceModel, useDefaultRotData : bool = true) -> void:
	if newCoinPieceModel == _coinPieceModel:
		return
	if _coinPieceModel != null:
		_unattachModel()
	var oldCoinPieceModel : CoinPieceModel = _coinPieceModel
	_coinPieceModel = newCoinPieceModel
	sprite.texture = _coinPieceModel.getTextureAtlas()
	var newSealModel : SealModel = _coinPieceModel.getSealModel()
	if newSealModel != null and _sealNode == null:
		await _onSealAdded(_coinPieceModel.getSealModel())
	elif newSealModel != null:
		await _onSealReplaced(newSealModel, _sealNode.getModel())
	elif _sealNode != null:
		await _onSealRemoved(_sealNode.getModel())
	if useDefaultRotData:
		if _coinPieceModel.coinPieceType == Entities.CoinPieceType.CORE:
			setRotationData(Util.getSocketIndexToCoinPieceRotData(Entities.CoinPieceSocketIndex.CORE))
		else:
			setRotationData(Util.getSocketIndexToCoinPieceRotData(Entities.CoinPieceSocketIndex.EXT_UP))
	_attachModel()
	model_changed.emit(newCoinPieceModel, oldCoinPieceModel)
	tooltipViewer.setLocalizedModel(newCoinPieceModel)

func getModel() -> CoinPieceModel:
	return _coinPieceModel

func setRotationData(rotData : CoinPieceRotData) -> void:
	sprite.rotation = rotData.getRotation()
	sprite.region_rect.position.y = sprite.region_rect.size.x * rotData.getAtlasIndex()
