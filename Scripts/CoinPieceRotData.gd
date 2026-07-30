extends RefCounted

class_name CoinPieceRotData

var _socketIndex : int = 0
var _rotation : float = 0.0
var _atlasIndex : int = 0
var _offset : Vector2i = Vector2i.ZERO

const DIST_STRAIGHT : int = 32
const DIST_ANGLED : int = 23

func _init(socketIndex : Entities.CoinPieceSocketIndex) -> void:
	if socketIndex == Entities.CoinPieceSocketIndex.NONE:
		push_error("ERROR: Socket Index NONE given to CoinPieceRotData._init. Using fallback.")
		socketIndex = Entities.CoinPieceSocketIndex.CORE
	_socketIndex = socketIndex
	if socketIndex == Entities.CoinPieceSocketIndex.CORE:
		_rotation = 0.0
		_atlasIndex = 0
		_offset = Vector2i.ZERO
	else:
		_rotation = ((socketIndex-1)/2) * PI/2.0
		_atlasIndex = ((socketIndex-1) % 2)
		var offFloat : Vector2 = (Vector2.UP).rotated(_rotation + (_atlasIndex * PI/4.0))
		_offset.x = int(_getRotDistInternal(offFloat.x))
		_offset.y = int(_getRotDistInternal(offFloat.y))

func _getRotDistInternal(val : float) -> float:
	if val > -0.01 and val < 0.01:
		return 0.0
	elif abs(val) == 1.0:
		return sign(val) * DIST_STRAIGHT
	else:
		return sign(val) * DIST_ANGLED

func getRotation() -> float:
	return _rotation
func getAtlasIndex() -> int:
	return _atlasIndex
func getOffset() -> Vector2i:
	return _offset
