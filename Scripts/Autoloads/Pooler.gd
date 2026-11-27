extends Node

const DEF_POOL_SIZE : int = 100
var defTypes : Array[Script] = [
	MatchStateDecision
]

var typeToReleasedObjects : Dictionary[Script, Array] = {}
var untracked : Dictionary[Script, int] = {}

func _ready() -> void:
	for objectType : Script in defTypes:
		initType(objectType)

func initType(objectType : Script) -> void:
	typeToReleasedObjects[objectType] = []
	untracked[objectType] = 0
	refreshPool(objectType)

func refreshPool(objectType : Script) -> void:
	for i in range(DEF_POOL_SIZE):
		typeToReleasedObjects[objectType].append(objectType.new())

func getSize(objectType : Script) -> int:
	if not typeToReleasedObjects.has(objectType):
		return -1
	return typeToReleasedObjects[objectType].size()

func getUntracked(objectType : Script) -> int:
	if not untracked.has(objectType):
		return -1
	return untracked[objectType]

func fetch(objectType : Script) -> Object:
	if typeToReleasedObjects[objectType].size() == 0:
		refreshPool(objectType)
	untracked[objectType] += 1
	return typeToReleasedObjects[objectType].pop_front()

func release(object : Object, objectType : Script = null) -> void:
	if objectType == null:
		objectType = object.get_script()
	untracked[objectType] -= 1
	typeToReleasedObjects[objectType].append(object)
