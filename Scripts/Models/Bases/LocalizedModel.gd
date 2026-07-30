@abstract
extends RefCounted

class_name LocalizedModel

####################################################################################################
#	BUILT-IN/PRIVATE FUNCS	#

func _init(data : Dictionary = {}) -> void:
	if data.is_empty():
		deserialize(getBaseData())
	else:
		deserialize(data)

####################################################################################################
#	OVERRIDE FUNCS	#

#Initial/Additional data for/from the model
func getBaseData() -> Dictionary: return {}
@abstract func getLocID() -> String

@warning_ignore("unused_parameter")
func deserialize(data : Dictionary) -> LocalizedModel:
	return self

func serialize() -> Dictionary:
	return {}

####################################################################################################
#	PUBLIC FUNCS	#

func isSame(other : LocalizedModel) -> bool:
	return get_script() == other.get_script()

func clone() -> LocalizedModel:
	var cloneModel : LocalizedModel = cloneBase()
	cloneModel.deserialize(serialize())
	return cloneModel

func cloneBase() -> LocalizedModel:
	return ModelDB.getModel(get_script())

func getLocalizedString(key : String) -> String:
	return Localization.getLocalizedData(getLocID() + "." + key)

func getTooltipString() -> String:
	return ""
