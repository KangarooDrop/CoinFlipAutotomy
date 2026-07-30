
enum CoinPieceSocketIndex {
	NONE = -1,
	CORE = 0,
	EXT_UP = 1,
	EXT_UP_RIGHT = 2,
	EXT_RIGHT = 3,
	EXT_DOWN_RIGHT = 4,
	EXT_DOWN = 5,
	EXT_DOWN_LEFT = 6,
	EXT_LEFT = 7,
	EXT_UP_LEFT = 8,
}

static func getRotated(socketIndex : CoinPieceSocketIndex, rotAmount : int) -> CoinPieceSocketIndex:
	if socketIndex == CoinPieceSocketIndex.NONE or socketIndex == CoinPieceSocketIndex.CORE:
		return CoinPieceSocketIndex.NONE
	return posmod(socketIndex+rotAmount-1, CoinPieceSocketIndex.EXT_UP_LEFT) + 1 as CoinPieceSocketIndex

static func getOpposite(socketIndex : CoinPieceSocketIndex) -> CoinPieceSocketIndex:
	return getRotated(socketIndex, 4)

static func getAllAdjacent(socketIndex : CoinPieceSocketIndex) -> Array[CoinPieceSocketIndex]:
	return [CoinPieceSocketIndex.CORE, getRotated(socketIndex, -1), getRotated(socketIndex, 1)]
