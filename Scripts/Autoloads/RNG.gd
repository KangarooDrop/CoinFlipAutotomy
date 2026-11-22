extends Node

func getRandi() -> int:
	return randi()

func getRandf() -> float:
	return randf()

var start_rng_accumulator : CFSignal = CFSignal.new()
var rng_enqueued : CFSignal = CFSignal.new()
var rng_queue_finished : CFSignal = CFSignal.new()
var end_rng_accumulator : CFSignal = CFSignal.new()


var isDeciding : bool = false
var finishedDeciding : bool = false
var lastMatchState : Variant = null
var decisionIndices : Array[int] = []
var decisionSizes : Array[int] = []
var currentIndex : int = 0

func _getWeightedRand(weights : Array[float]) -> int:
	var totalWeight : float = 0.0
	for i in range(weights.size()):
		totalWeight += weights[i]
	var rand : float = totalWeight * randf()
	for i in range(weights.size()):
		rand -= weights[i]
		if rand < 0.0:
			return i
	return weights.size()-1

func select(matchState : MatchState, from : Array[Variant]) -> Variant:
	var weightedDict : Dictionary[Variant, float] = {}
	for val : Variant in from:
		weightedDict[val] = 1
	return selectWeighted(matchState, weightedDict)

func selectRate(matchState : MatchState, rate : float) -> bool:
	var out = selectWeighted(matchState, {true : rate, false : (1.0-rate)})
	if out == null:
		return false
	return out

func selectWeighted(matchState : MatchState, dict : Dictionary[Variant, float]) -> Variant:
	var from : Array = dict.keys()
	if matchState != null and matchState.rngQueue.size() > 0:
		return from[matchState.rngQueue.pop_front() % from.size()]
	elif not isDeciding:
		var index : int = _getWeightedRand(dict.values())
		return from[index % from.size()]
	else:
		if finishedDeciding:
			return null
		if lastMatchState == null:
			start_rng_accumulator.emitSignal()
		if matchState != lastMatchState:
			if lastMatchState != null:
				rng_queue_finished.emitSignal()
			lastMatchState = matchState
			currentIndex = 0
		if currentIndex >= decisionIndices.size():
			if currentIndex != 0:
				decisionIndices[currentIndex-1] -= 1
			decisionIndices.append(0)
			decisionSizes.append(from.size())
		while decisionIndices.size()>0 and decisionIndices[decisionIndices.size()-1] >= decisionSizes[decisionIndices.size()-1]:
			var endIndex : int = decisionIndices.size()-1
			if endIndex != 0:
				decisionIndices[endIndex-1] += 1
			decisionIndices.remove_at(endIndex)
			decisionSizes.remove_at(endIndex)
		
		var rtn = null
		var ended = currentIndex >= decisionIndices.size()
		if not ended:
			rtn = from[decisionIndices[currentIndex]]
			rng_enqueued.emitSignal(decisionIndices[currentIndex])
			if currentIndex == decisionIndices.size()-1:
				decisionIndices[currentIndex] += 1
			currentIndex += 1
		
		"""
		print("source=", source)
		print(decisionIndices)
		print(decisionSizes)
		print("index=", currentIndex)
		print("rtn=", rtn)
		print()
		"""
		
		if ended:
			lastMatchState = null
			finishedDeciding = true
			end_rng_accumulator.emitSignal()
		
		return rtn

####################################################################################################

func getNRandomCoinPieces(matchState : MatchState, coinFaceModel : CoinFaceModel, num : int, verifyCallable : Callable = Util.callableFuncTrue) -> Array[CoinPieceModel]:
	var allCoinPieceModels : Array[CoinPieceModel] = coinFaceModel.getAllPieces()
	for i in range(allCoinPieceModels.size()-1, -1, -1):
		if not verifyCallable.call(allCoinPieceModels[i]):
			allCoinPieceModels.remove_at(i)
	var rtn : Array[CoinPieceModel] = []
	while num > 0 and allCoinPieceModels.size() > 0:
		var out : CoinPieceModel = select(matchState, allCoinPieceModels)
		allCoinPieceModels.erase(out)
		num -= 1
		rtn.append(out)
	return rtn

func getRandomCoinPiece(matchState : MatchState, coinFaceModel : CoinFaceModel) -> CoinPieceModel:
	return Util.getFirstOrNull(getNRandomCoinPieces(matchState, coinFaceModel, 1))

func getNRandomCoinPiecesNonSeal(matchState : MatchState, coinFaceModel : CoinFaceModel, num : int) -> Array[CoinPieceModel]:
	return getNRandomCoinPieces(matchState, coinFaceModel, num, 
		func(cpmCheck : CoinPieceModel):
			return not cpmCheck.hasSeal()
			)

func getRandomCoinPieceNonSeal(matchState : MatchState, coinFaceModel : CoinFaceModel) -> CoinPieceModel:
	return Util.getFirstOrNull(getNRandomCoinPiecesNonSeal(matchState, coinFaceModel, 1))

func getNRandomAdjacent(matchState : MatchState, coinPieceModel : CoinPieceModel, num : int, verifyCallable : Callable = Util.callableFuncTrue) -> Array[CoinPieceModel]:
	if coinPieceModel == null or not matchState.hasTriggerable(coinPieceModel):
		push_error("ERROR: Invalid Coin Piece Model given to RNG.getNRandomAdjacent")
		return []
	var coinFaceModel : CoinFaceModel = coinPieceModel.getCoinFaceModel()
	if coinFaceModel == null:
		push_error("ERROR: Could not get CoinFaceModel from CoinPieceModel given to RNG.getNRandomAdjacent")
		return []
	var adjacentCoinPieceModels : Array[CoinPieceModel] = coinFaceModel.getAdjacentCoinPieces(coinPieceModel)
	for i in range(adjacentCoinPieceModels.size()-1, -1, -1):
		if not verifyCallable.call(adjacentCoinPieceModels[i]):
			adjacentCoinPieceModels.remove_at(i)
	var rtn : Array[CoinPieceModel] = []
	while num > 0 and adjacentCoinPieceModels.size() > 0:
		var out : CoinPieceModel = select(matchState, adjacentCoinPieceModels)
		adjacentCoinPieceModels.erase(out)
		num -= 1
		rtn.append(out)
	return rtn

func getRandomAdjacent(matchState : MatchState, coinPieceModel : CoinPieceModel) -> CoinPieceModel:
	return Util.getFirstOrNull(getNRandomAdjacent(matchState, coinPieceModel, 1))

func getNRandomAdjacentNonSeal(matchState : MatchState, coinPieceModel : CoinPieceModel, num : int) -> Array[CoinPieceModel]:
	return getNRandomAdjacent(matchState, coinPieceModel, num, 
		func(cpmCheck : CoinPieceModel):
			return not cpmCheck.hasSeal()
			)

func getRandomAdjacentNonSeal(matchState : MatchState, coinPieceModel : CoinPieceModel) -> CoinPieceModel:
	return Util.getFirstOrNull(getNRandomAdjacentNonSeal(matchState, coinPieceModel, 1))
