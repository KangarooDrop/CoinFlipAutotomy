extends RefCounted

class_name CoinFaceModel

var _playerModel : PlayerModel = null

var _socketIndexToPiece : Dictionary[Entities.CoinPieceSocketIndex, CoinPieceModel] = {}

signal coin_piece_added(socketIndex : Entities.CoinPieceSocketIndex, coinPieceModel : CoinPieceModel)
signal coin_piece_removed(socketIndex : Entities.CoinPieceSocketIndex, coinPieceModel : CoinPieceModel)
signal coin_piece_replaced(socketIndex : Entities.CoinPieceSocketIndex, newCoinPieceModel : CoinPieceModel, oldCoinPieceModel : CoinPieceModel)

####################################################################################################

func _init() -> void:
	for socketIndex : Entities.CoinPieceSocketIndex in Entities.getAllNonNone(Entities.CoinPieceSocketIndex):
		_socketIndexToPiece[socketIndex] = null

func _setCoinPieceInternal(socketIndex : Entities.CoinPieceSocketIndex, coinPieceModel : CoinPieceModel) -> CoinPieceModel:
	var oldCoinPieceModel = getCoinPieceAtSocket(socketIndex)
	if oldCoinPieceModel != null:
		oldCoinPieceModel.setCoinFaceModel(null)
	_socketIndexToPiece[socketIndex] = coinPieceModel
	coinPieceModel.setCoinFaceModel(self)
	return oldCoinPieceModel

func _hasSocket(socketIndex : Entities.CoinPieceSocketIndex) -> bool:
	return _socketIndexToPiece.has(socketIndex)

####################################################################################################

func clone() -> CoinFaceModel:
	var cloneModel : CoinFaceModel = get_script().new()
	cloneModel.setPlayerModel(_playerModel)
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToPiece.keys():
		if _socketIndexToPiece[socketIndex] == null:
			continue
		cloneModel.insertCoinPiece(socketIndex, _socketIndexToPiece[socketIndex].clone())
	return cloneModel

####################################################################################################

func getPlayerModel() -> PlayerModel:
	return _playerModel
func setPlayerModel(newPlayerModel : PlayerModel) -> void:
	_playerModel = newPlayerModel

func getNextIndex(coinPieceType : Entities.CoinPieceType) -> Entities.CoinPieceSocketIndex:
	if coinPieceType == Entities.CoinPieceType.NONE:
		return Entities.CoinPieceSocketIndex.NONE
	elif coinPieceType == Entities.CoinPieceType.CORE:
		return Entities.CoinPieceSocketIndex.CORE if getCoinPieceAtSocket(Entities.CoinPieceSocketIndex.CORE) == null else Entities.CoinPieceSocketIndex.NONE
	else:
		for socketIndex : Entities.CoinPieceSocketIndex in Entities.getAllExceptVals(Entities.CoinPieceSocketIndex, [Entities.CoinPieceSocketIndex.CORE, Entities.CoinPieceSocketIndex.NONE]):
			if _socketIndexToPiece[socketIndex] == null:
				return socketIndex
	return Entities.CoinPieceSocketIndex.NONE

func getUsedSocketIndices() -> Array[Entities.CoinPieceSocketIndex]:
	var rtn : Array[Entities.CoinPieceSocketIndex] = []
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToPiece.keys():
		if getCoinPieceAtSocket(socketIndex) != null:
			rtn.append(socketIndex)
	return rtn

func getCore() -> CoinPieceModel:
	return _socketIndexToPiece[Entities.CoinPieceSocketIndex.CORE]

func getExteriors() -> Array[CoinPieceModel]:
	var rtn : Array[CoinPieceModel] = []
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToPiece.keys():
		if socketIndex != Entities.CoinPieceSocketIndex.CORE and _socketIndexToPiece[socketIndex] != null:
			rtn.append(_socketIndexToPiece[socketIndex])
	return rtn

func getAllPieces() -> Array[CoinPieceModel]:
	var rtn : Array[CoinPieceModel] = []
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToPiece.keys():
		if _socketIndexToPiece[socketIndex] != null:
			rtn.append(_socketIndexToPiece[socketIndex])
	return rtn

func getAllSeals() -> Array[SealModel]:
	var rtn : Array[SealModel] = []
	for coinPieceModel : CoinPieceModel in getAllPieces():
		var sealModel : SealModel = coinPieceModel.getSealModel()
		if sealModel != null:
			rtn.append(sealModel)
	return rtn

func getCoinPieceAtSocket(socketIndex : Entities.CoinPieceSocketIndex) -> CoinPieceModel:
	if not _socketIndexToPiece.has(socketIndex):
		return null
	return _socketIndexToPiece[socketIndex]

func addCoinPieceToNextSocket(coinPieceModel : CoinPieceModel) -> bool:
	var nextIndex : Entities.CoinPieceSocketIndex = getNextIndex(coinPieceModel.coinPieceType)
	if nextIndex == Entities.CoinPieceSocketIndex.NONE:
		return false
	insertCoinPiece(nextIndex, coinPieceModel)
	return true

func insertCoinPiece(socketIndex : Entities.CoinPieceSocketIndex, coinPieceModel : CoinPieceModel) -> CoinPieceModel:
	if not _hasSocket(socketIndex):
		return null
	var oldCoinPieceModel : CoinPieceModel = _setCoinPieceInternal(socketIndex, coinPieceModel)
	if oldCoinPieceModel == null:
		coin_piece_added.emit(socketIndex, coinPieceModel)
	else:
		coin_piece_replaced.emit(socketIndex, coinPieceModel, oldCoinPieceModel)
	return oldCoinPieceModel

func removeCoinPieceFromSocket(socketIndex : Entities.CoinPieceSocketIndex) -> CoinPieceModel:
	if not _hasSocket(socketIndex):
		return null
	var oldCoinPieceModel : CoinPieceModel = _setCoinPieceInternal(socketIndex, null)
	if oldCoinPieceModel != null:
		coin_piece_removed.emit(socketIndex, oldCoinPieceModel)
	return oldCoinPieceModel

func eraseCoinPiece(coinPieceModel : CoinPieceModel) -> bool:
	var cpIndex : Entities.CoinPieceSocketIndex = Entities.CoinPieceSocketIndex.NONE
	for nextIndex : Entities.CoinPieceSocketIndex in Entities.getAllNonNone(Entities.CoinPieceSocketIndex):
		if _socketIndexToPiece[nextIndex] == coinPieceModel:
			cpIndex = nextIndex
			break
	return removeCoinPieceFromSocket(cpIndex) != null

func hasCoinPieceModel(coinPieceModel : CoinPieceModel) -> bool:
	return coinPieceModel != null and _socketIndexToPiece.values().has(coinPieceModel)

func getSocketIndexFromCoinPieceModel(coinPieceModel : CoinPieceModel) -> Entities.CoinPieceSocketIndex:
	for socketIndex : Entities.CoinPieceSocketIndex in _socketIndexToPiece.keys():
		if _socketIndexToPiece[socketIndex] == coinPieceModel:
			return socketIndex
	return Entities.CoinPieceSocketIndex.NONE
