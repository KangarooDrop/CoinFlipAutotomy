extends Control

class_name TooltipViewer

var _text : String = ""
var _localizedModel : LocalizedModel = null

var _hoveringViewer : bool = false
var _tooltipShowWaitTimer : float = 0.0
var _tooltipHideWaitTimer : float = 0.0

var _tooltip : Tooltip = null

const TOOLTIP_SHOW_WAIT_MAX_TIME : float = 0.0
const TOOLTIP_HIDE_WAIT_MAX_TIME : float = 0.15

####################################################################################################

func _process(delta: float) -> void:
	if isMouseHovering() and _tooltip == null:
		_tooltipShowWaitTimer += delta
		if _tooltipShowWaitTimer >= TOOLTIP_SHOW_WAIT_MAX_TIME:
			_createTooltip()
	else:
		_tooltipShowWaitTimer = 0.0
	
	if not isMouseHovering() and _tooltip != null:
		_tooltipHideWaitTimer += delta
		if _tooltipHideWaitTimer >= TOOLTIP_HIDE_WAIT_MAX_TIME:
			_removeTooltip()
	else:
		_tooltipHideWaitTimer = 0.0

func _createTooltip() -> void:
	var tooltipGlobalPos : Vector2 = global_position + size/2.0
	var text : String = _text
	if _localizedModel != null:
		text = _localizedModel.getTooltipString()
	_tooltip = TooltipHandler.makeTooltip(tooltipGlobalPos, text)

func _removeTooltip() -> void:
	TooltipHandler.removeTooltip(_tooltip)
	_tooltip = null

func _onMouseEnter() -> void:
	_hoveringViewer = true
func _onMouseExit() -> void:
	_hoveringViewer = false

func _exit_tree() -> void:
	if is_instance_valid(_tooltip):
		_removeTooltip()

####################################################################################################

func setText(newText : String) -> void:
	_text = newText
	_localizedModel = null

func setLocalizedModel(newLocalizedModel : LocalizedModel) -> void:
	_localizedModel = newLocalizedModel
	_text = ""

func isMouseHovering() -> bool:
	return _hoveringViewer
