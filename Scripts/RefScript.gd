@abstract
extends Node

class_name _RefScript

#ENUMS
enum EnumType {
	ITEM_0,
	ITEM_1,
}

#CONSTANTS
const CONSTANT_NAME : int = 0

#PUBLIC VARIABLES
var publicVar : float = 0.0

#PRIVATE VARIABLES
var _privateVar : float = 0.0

#export vars
@export var exportVar : float = 0.0

#ONREADY VARIABLES
@onready var onreadyNode : Node = get_node("%NodePath")

#SIGNALS
signal signal_happened(signalVar : float)

####################################################################################################
#	PRIVATE/INNER CLASSES	#
class InnerClass:
	pass

####################################################################################################
#	BUILT-IN/PRIVATE FUNCS	#

func _init() -> void:
	_privateVar = 1.0
	signal_happened.emit(_privateVar)

func _privateFunc() -> void:
	pass

func _privateCallbackOnSignal() -> void:
	pass

####################################################################################################
#	OVERLOADED FUNCS	#

func nestedOverloadFunc() -> String:
	#In Inhereted Class: return super.nestedOverloadFunc() + ".name"
	return "Func"

@abstract func _funcToOverload() -> String

####################################################################################################
#	PUBLIC FUNCS	#

func publicCallbackOnSignal() -> void:
	pass

func getPrivateVar() -> float:
	return _privateVar
