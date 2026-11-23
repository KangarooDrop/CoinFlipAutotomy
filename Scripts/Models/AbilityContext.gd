extends Serializable

class_name AbilityContext

const KEY_SOURCE : String = "source"
const KEY_TARGETS : String = "targets"
const KEY_IS_COUNTERED : String = "is_countered"
const KEY_IS_COPY : String = "is_copy"

var source : Variant = null
var targets : Array = []

var isCountered : bool = false
var isCopy : bool = false

####################################################################################################

func _getBaseData() -> Dictionary:
	return {}
func _initBaseData(_data : Dictionary) -> void:
	pass

func serialize() -> Dictionary:
	var rtn : Dictionary = {}
	rtn[KEY_SOURCE] = source
	rtn[KEY_TARGETS] = targets.duplicate()
	rtn[KEY_IS_COUNTERED] = isCountered
	rtn[KEY_IS_COPY] = isCopy
	return rtn
func deserialize(data : Dictionary) -> Serializable:
	if data.has(KEY_SOURCE):
		source = data[KEY_SOURCE]
	if data.has(KEY_TARGETS):
		targets = data[KEY_TARGETS]
	if data.has(KEY_IS_COUNTERED):
		isCountered = data[KEY_IS_COUNTERED]
	if data.has(KEY_IS_COPY):
		isCopy = data[KEY_IS_COPY]
	return self

func clone() -> Serializable:
	return get_script().new(serialize())

####################################################################################################

func _init(newSource : Variant, newTargets : Array) -> void:
	self.source = newSource
	self.targets = newTargets

func getPlayerModel() -> PlayerModel:
	if source != null and source.has_method("getPlayerModel"):
		return source.getPlayerModel()
	return null
