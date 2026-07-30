extends Control

const LOAD_TIME_MAX : float = 2.0

var _showingLoadScreen : bool = false
var _loadTimer : float = 0.0

@onready var shaderMat : ShaderMaterial = material as ShaderMaterial

signal loading_screen_shown
signal loading_screen_hidden

####################################################################################################

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if _showingLoadScreen and _loadTimer<LOAD_TIME_MAX:
		_loadTimer += delta
		_updateShader()
		if _loadTimer >= LOAD_TIME_MAX:
			loading_screen_shown.emit()
	elif not _showingLoadScreen and _loadTimer>0:
		_loadTimer -= delta
		_updateShader()
		if _loadTimer <= 0:
			hide()
			loading_screen_hidden.emit()

func _updateShader() -> void:
	var t : float = max(0.0, min(1.0, _loadTimer/LOAD_TIME_MAX))
	shaderMat.set_shader_parameter("t", pow(t, 1.0))

####################################################################################################

func showLoadScreen() -> void:
	_showingLoadScreen = true
	show()

func hideLoadScreen() -> void:
	_showingLoadScreen = true
