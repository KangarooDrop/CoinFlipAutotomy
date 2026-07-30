extends RefCounted

class_name SubDB

var _models : Array[LocalizedModel] = []
var _scriptToModel : Dictionary [Script, LocalizedModel] = {}
var _scriptToIndex : Dictionary [Script, int]

####################################################################################################

func _cloneIfNotNull(model : LocalizedModel) -> LocalizedModel:
	if model == null:
		return null
	return model.get_script().new().deserialize(model.serialize())

func _insert(model : LocalizedModel) -> void:
	var scr : Script = model.get_script()
	if _scriptToModel.has(scr):
		_models.erase(_scriptToModel[scr])
	_scriptToModel[scr] = model
	_scriptToIndex[scr] = _models.size()
	_models.append(model)

####################################################################################################

func merge(otherSubDB : SubDB) -> void:
	for model in otherSubDB._models:
		_insert(model)

func add(scr : Script) -> void:
	_insert(scr.new())

func getModelByScript(scr : Script) -> LocalizedModel:
	return _cloneIfNotNull(getModelByScriptSingleton(scr))

func getModelByScriptSingleton(scr : Script) -> LocalizedModel:
	if not _scriptToModel.has(scr):
		return null
	return _scriptToModel[scr]

func getByIndex(index : int) -> LocalizedModel:
	if index < 0 or index >= _models.size():
		return null
	return _models[index]

func getIndexByScript(scr : Script) -> int:
	if not _scriptToIndex.has(scr):
		return -1
	return _scriptToIndex[scr]

func getRandomScript() -> Script:
	return getRandomScriptNoRepeat(1)[0]

func getRandomScriptNoRepeat(num : int) -> Array[Script]:
	var scriptArray : Array = _scriptToModel.keys()
	num = min(scriptArray.size(), num)
	var rtn : Array[Script] = []
	for i in range(num):
		var index : int = randi() % scriptArray.size()
		rtn.append(scriptArray[index])
		scriptArray.remove_at(index)
	return rtn
