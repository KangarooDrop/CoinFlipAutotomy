@abstract
extends RefCounted

class_name Serializable

func _init(data : Dictionary = {}) -> void:
	if data.is_empty():
		_initBaseData(_getBaseData())
	else:
		deserialize(data)

################################################################################

#The database information of the class, such as name, target type, etc.
#May refer to scripts, so cannot be stringified
func _getBaseData() -> Dictionary:
	return {}
func _initBaseData(_data : Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	return {}
func deserialize(_data : Dictionary) -> Serializable:
	return self

func clone() -> Serializable:
	return get_script().new(serialize())
