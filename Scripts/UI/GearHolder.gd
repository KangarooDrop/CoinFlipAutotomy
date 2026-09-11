extends Node

class_name GearHolder

@export var flipH : bool = false

@onready var handNode : HandNode = get_node("HandNode")
@onready var coinFaceNode : CoinFaceNode = get_node("CoinFaceNode")

func _ready() -> void:
	handNode.setFlipped(flipH)
