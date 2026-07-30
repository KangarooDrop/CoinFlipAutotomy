extends Node

var _listenerToCallable : Dictionary = {}

var _langString : String = ""
var _table : Dictionary = {}

const _locFolderPath : String = "res://Localization"
const _validLanguages : Array = \
[
	"eng",
	"spa",
	
]
const _defLang : String = "eng"

func _ready() -> void:
	setLanguage(_defLang)

func _getTableFromPath(path : String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("ERROR: Could not find table at path ", path)
		return {}
	var text : String = FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(text)
	if json == null:
		push_error("ERROR: Could not parse JSON at path ", path)
		return {}
	return json

func _loadTable(lang : String) -> void:
	if not lang in _validLanguages:
		push_error("ERROR: Language ", lang, " does not exist.")
		return
	if lang == _langString:
		return
	
	_table = _getTableFromPath(_locFolderPath + "/" + lang + ".json")
	_langString = lang
	for listener : Object in _listenerToCallable.keys():
		(_listenerToCallable[listener] as Callable).call()
	print("Set language to ", lang)

####################################################################################################

func addListener(listener : Object, callable : Callable) -> void:
	_listenerToCallable[listener] = callable

func removeListener(listener : Object) -> void:
	_listenerToCallable.erase(listener)

func setLanguage(lang : String) -> void:
	_loadTable(lang)

func getLocalizedData(locID : String) -> String:
	var locKeys : PackedStringArray = locID.rsplit(".")
	var d = _table
	for subID : String in locKeys:
		if not d.has(subID):
			push_error("ERROR: Could not find locID=", locID, " in table=", _langString)
			return ""
		d = d[subID]
	return d
