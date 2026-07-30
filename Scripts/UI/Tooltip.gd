extends Node2D

class_name Tooltip

enum TTDir {LEFT, RIGHT}

const SCREEN_BUFFER : int = 4
const WIDTH : int = 212

var _dir : TTDir = TTDir.RIGHT
var _text : String = ""
var _localized : bool = false
var _mouseHovering : bool = false

@onready var label : Label = get_node("%Label")
@onready var marginContainer : MarginContainer = get_node("%MarginContainer")
@onready var window : Control = get_node("%Window")
@onready var mouseHoverControl : Control = get_node("%MouseHoverControl")

####################################################################################################

func _exit_tree() -> void:
	if _localized:
		_localized = false
		Localization.removeListener(self)

func _onLanguageChange() -> void:
	_setTextInternal(Localization.getLocalizedData(_text))

func _setTextInternal(text : String) -> void:
	label.text = text
	label.size.y = 0.0
	_updateWindow.call_deferred()

func _updateWindow() -> void:
		marginContainer.size.y = 0.0
		marginContainer.position.y = -marginContainer.size.y/2.0
		if _dir == TTDir.LEFT:
			marginContainer.position.x = -marginContainer.size.x
		elif _dir == TTDir.RIGHT:
			marginContainer.position.x = 0.0
		
		window.size = marginContainer.size
		window.position = marginContainer.position
		mouseHoverControl.size = window.size
		mouseHoverControl.position = window.position
		
		var bottomDiff : float = global_position.y + marginContainer.size.y/2.0 - Util.screenHeight + SCREEN_BUFFER
		if bottomDiff > 0.0:
			position.y -= bottomDiff
		
		var topDiff : float = SCREEN_BUFFER - (global_position.y - marginContainer.size.y/2.0)
		if topDiff > 0.0:
			position.y += topDiff
		
		var rightDiff : float = global_position.x - Util.screenWidth + SCREEN_BUFFER
		if _dir == TTDir.RIGHT:
			rightDiff += marginContainer.size.x
		if rightDiff > 0.0:
			position.x -= rightDiff
		
		var leftDiff : float = SCREEN_BUFFER - global_position.x
		if _dir == TTDir.LEFT:
			rightDiff += marginContainer.size.x
		if leftDiff > 0.0:
			position.x += leftDiff

func _onMouseEnter() -> void:
	_mouseHovering = true
func _onMouseExit() -> void:
	_mouseHovering = false

####################################################################################################

func isMouseHovering() -> bool:
	return _mouseHovering

func setDir(dir : TTDir) -> void:
	_dir = dir
	if not _text.is_empty():
		_updateWindow()

func setText(text : String) -> void:
	if _localized:
		Localization.removeListener(self)
		_localized = false
	_text = text
	_setTextInternal(text)

func setLocText(locID : String, locKey : String = "") -> void:
	if not locKey.is_empty():
		locID += "." + locKey
	_text = locID
	if not _localized:
		Localization.addListener(self, _onLanguageChange)
		_localized = true
	_onLanguageChange()
