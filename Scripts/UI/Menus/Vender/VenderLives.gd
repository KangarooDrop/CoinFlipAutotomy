extends Control

@onready var _textureRect : TextureRect = get_node("%TextureRect")
@onready var _atlasTexture : AtlasTexture = _textureRect.texture as AtlasTexture
@onready var _atlasOffset : float = _atlasTexture.region.size.y

func _ready() -> void:
	RunManager.num_lives_changed.connect(_livesChanged)
	_livesChanged()

func _livesChanged() -> void:
	_atlasTexture.region.position.y = RunManager.getNumLives() * _atlasOffset
