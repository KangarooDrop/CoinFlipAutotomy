@abstract
extends Serializable
class_name LocalizedModel

const IS_VISIBLE_KEY : String = "is_visible"

var isVisible : bool = true

####################################################################################################
#	OVERRIDE FUNCS	#

@abstract func getLocID() -> String

#Initial/Additional data for/from the model
func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		IS_VISIBLE_KEY : true,
	}, true)
	return baseData

func _initBaseData(data : Dictionary) -> void:
	super._initBaseData(data)
	if data.has(IS_VISIBLE_KEY):
		isVisible = data[IS_VISIBLE_KEY]

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn[ModelDB.DB_INDEX_KEY] = ModelDB.getModelToDBIndex(self)
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	super.deserialize(data)
	return self

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

####################################################################################################
#	PUBLIC FUNCS	#

func isSame(other : LocalizedModel) -> bool:
	return get_script() == other.get_script()

func getLocalizedString(key : String) -> String:
	return Localization.getLocalizedData(getLocID() + "." + key)

func getTooltipString() -> String:
	return ""
