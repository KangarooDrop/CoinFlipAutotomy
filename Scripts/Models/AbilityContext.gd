extends RefCounted

class_name AbilityContext

var source : Variant = null
var targets : Array = []

var isCountered : bool = false
var isCopy : bool = false

func _init(newSource : Variant, newTargets : Array) -> void:
	self.source = newSource
	self.targets = newTargets

func getPlayerModel() -> PlayerModel:
	if source != null and source.has_method("getPlayerModel"):
		return source.getPlayerModel()
	return null
