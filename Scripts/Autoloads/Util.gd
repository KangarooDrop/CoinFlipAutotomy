extends Node

@onready var _socketIndexToCoinPieceRotData : Dictionary[Entities.CoinPieceSocketIndex, CoinPieceRotData] = _initSocketIndexToPieceRotData()
static func _initSocketIndexToPieceRotData() -> Dictionary:
	var rtn : Dictionary[Entities.CoinPieceSocketIndex, CoinPieceRotData] = {}
	for socketIndex : Entities.CoinPieceSocketIndex in Entities.getAllNonNone(Entities.CoinPieceSocketIndex):
		rtn[socketIndex] = CoinPieceRotData.new(socketIndex)
	return rtn

func getSocketIndexToCoinPieceRotData(socketIndex : Entities.CoinPieceSocketIndex) -> CoinPieceRotData:
	if not _socketIndexToCoinPieceRotData.has(socketIndex):
		push_error("ERROR: Invalid index given to Util.getIndexToCoinPieceRotData. Using fallback of CORE.")
		return _socketIndexToCoinPieceRotData[Entities.CoinPieceSocketIndex.CORE]
	else:
		return _socketIndexToCoinPieceRotData[socketIndex]

var screenWidth : float = ProjectSettings.get("display/window/size/viewport_width")
var screenHeight : float = ProjectSettings.get("display/window/size/viewport_height")

const INT_MAX : int = 2147483647

func hasBitVal(val : int, bitVal : int) -> bool:
	return val & bitVal == bitVal

func betterCeil(val : Variant) -> Variant:
	if typeof(val) == TYPE_FLOAT:
		return ceil(val) if val > 0 else floor(val)
	elif typeof(val) == TYPE_VECTOR2:
		return Vector2(betterCeil(val.x), betterCeil(val.y))
	else:
		return val

func betterFloor(val : Variant) -> Variant:
	if typeof(val) == TYPE_FLOAT:
		return floor(val) if val > 0 else ceil(val)
	elif typeof(val) == TYPE_VECTOR2:
		return Vector2(betterFloor(val.x), betterFloor(val.y))
	else:
		return val

func arrayAND(arr0 : Array, arr1 : Array) -> Array:
	var rtn : Array = []
	for val in arr0:
		if val in arr1:
			rtn.append(val)
	return rtn

func arrayOR(arr0 : Array, arr1 : Array) -> Array:
	var rtn : Array = arr0.duplicate()
	for val in arr1:
		if not val in rtn:
			rtn.append(val)
	return rtn

func arraySUB(arr0 : Array, arr1 : Array) -> Array:
	var rtn : Array = []
	for val in arr0:
		if not val in arr1:
			rtn.append(val)
	return rtn

func arrayXOR(arr0 : Array, arr1 : Array) -> Array:
	return arraySUB(arrayOR(arr0, arr1), arrayAND(arr0, arr1))

const NUM_PERCENT_FIGS : int = 5
func toPercent(val : float) -> float:
	return int(val * pow(10, NUM_PERCENT_FIGS)) / pow(10, NUM_PERCENT_FIGS-2)
