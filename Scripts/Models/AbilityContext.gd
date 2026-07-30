extends RefCounted

class_name AbilityContext

var source : Variant = null
var targets : Array = []

var isCountered : bool = false

func _init(newSource : Variant, newTargets : Array) -> void:
	self.source = newSource
	self.targets = newTargets
