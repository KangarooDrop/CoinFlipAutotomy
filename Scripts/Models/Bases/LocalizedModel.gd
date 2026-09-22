@abstract
extends RefCounted
class_name LocalizedModel

const IS_VISIBLE_KEY : String = "is_visible"

var isVisible : bool = true

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
func getBaseData() -> Dictionary:
	return {
		IS_VISIBLE_KEY : true
	}
@abstract func getLocID() -> String

@warning_ignore("unused_parameter")
func deserialize(data : Dictionary) -> LocalizedModel:
	if data.has(IS_VISIBLE_KEY):
		isVisible = data[IS_VISIBLE_KEY]
	return self

func serialize() -> Dictionary:
	return {
		IS_VISIBLE_KEY : isVisible
	}

####################################################################################################
#	PUBLIC FUNCS	#

func isSame(other : LocalizedModel) -> bool:
	return get_script() == other.get_script()

func clone() -> LocalizedModel:
	var cloneModel : LocalizedModel = cloneBase()
	cloneModel.deserialize(serialize())
	return cloneModel

func cloneBase() -> LocalizedModel:
	var selfScript : Script = get_script()
	var model : LocalizedModel = ModelDB.getModel(selfScript)
	if model != null:
		return model
	else:
		return selfScript.new()

func getLocalizedString(key : String) -> String:
	return Localization.getLocalizedData(getLocID() + "." + key)

func getTooltipString() -> String:
	return ""
