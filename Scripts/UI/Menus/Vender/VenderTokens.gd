extends Control

@onready var label : Label = get_node("%Label")

func _ready() -> void:
	RunManager.num_tokens_changed.connect(_tokensChanged)
	_tokensChanged()

func _tokensChanged() -> void:
	label.text = "x" + str(RunManager.getNumTokens())
