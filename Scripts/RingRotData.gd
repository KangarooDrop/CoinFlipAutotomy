extends RefCounted

class_name RingRotData

var _rotDir : int = 0
var _offset : Vector2i = Vector2i.ZERO

func _init(offset : Vector2i, rotDir : int) -> void:
	self._offset = offset
	self._rotDir = rotDir

func getRotation(flipH : bool = false) -> float:
	var flipIndexShift : int = 0 if (not flipH or _rotDir%2==0) else 2
	return (_rotDir + flipIndexShift) * PI/2.0
func getOffset(flipH : bool = false) -> Vector2i:
	return _offset if not flipH else _offset * Vector2i(-1, 1)
