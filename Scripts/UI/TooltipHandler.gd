extends CanvasLayer

var _showTimers : Dictionary[Tooltip, float] = {}
var _hideTimers : Dictionary[Tooltip, float] = {}

const SHOW_MAX_TIME : float = 0.125
const HIDE_MAX_TIME : float = 0.0
const OFFSET : float = 16.0
const POP_MAX_SCALE : float = 1.1
const POP_MAX_ROT : float = PI/32.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var tooltips : Array[Tooltip] = _showTimers.keys()
	for i in range(tooltips.size()-1, -1, -1):
		var tooltip : Tooltip = tooltips[i]
		_showTimers[tooltip] += delta
		tooltip.modulate.a = min(1.0, _showTimers[tooltip]/SHOW_MAX_TIME)
		if _showTimers[tooltip] >= SHOW_MAX_TIME:
			_showTimers.erase(tooltip)
	
	tooltips = _hideTimers.keys()
	for i in range(tooltips.size()-1, -1, -1):
		var tooltip : Tooltip = tooltips[i]
		_hideTimers[tooltip] += delta
		tooltip.modulate.a = 1.0 - min(1.0, _hideTimers[tooltip]/HIDE_MAX_TIME)
		if _hideTimers[tooltip] >= HIDE_MAX_TIME:
			_hideTimers.erase(tooltip)
			tooltip.queue_free()

func _makeTooltipInternal(globalPosition : Vector2, ignoreOffset : bool = false) -> Tooltip:
	var tooltip : Tooltip = Preloader.create(Preloader.tooltipPacked)
	add_child(tooltip)
	var ttDir : Tooltip.TTDir = Tooltip.TTDir.RIGHT
	if globalPosition.x > Util.screenWidth - Tooltip.WIDTH - Tooltip.SCREEN_BUFFER:
		ttDir = Tooltip.TTDir.LEFT
	tooltip.global_position = globalPosition
	if not ignoreOffset:
		tooltip.global_position.x += OFFSET if (ttDir == Tooltip.TTDir.RIGHT) else -OFFSET
	tooltip.setDir(ttDir)
	_showTimers[tooltip] = 0.0
	tooltip.modulate.a = 0.0
	var scaleTween : Tween = get_tree().create_tween().bind_node(tooltip).set_trans(Tween.TRANS_QUAD)
	scaleTween.tween_property(tooltip, "scale", Vector2.ONE * POP_MAX_SCALE, SHOW_MAX_TIME/2.0).set_ease(Tween.EASE_OUT)
	scaleTween.tween_property(tooltip, "scale", Vector2.ONE, SHOW_MAX_TIME/2.0).set_ease(Tween.EASE_IN)
	var rotTween : Tween = get_tree().create_tween().bind_node(tooltip).set_trans(Tween.TRANS_QUAD)
	rotTween.tween_property(tooltip, "rotation", POP_MAX_ROT, SHOW_MAX_TIME/4.0).set_ease(Tween.EASE_IN_OUT)
	rotTween.tween_property(tooltip, "rotation", -POP_MAX_ROT, SHOW_MAX_TIME/2.0).set_ease(Tween.EASE_IN_OUT)
	rotTween.tween_property(tooltip, "rotation", 0.0, SHOW_MAX_TIME/4.0).set_ease(Tween.EASE_IN_OUT)
	return tooltip

func makeTooltip(globalPosition : Vector2, text : String, ignoreOffset : bool = false) -> Tooltip:
	var tooltip : Tooltip = _makeTooltipInternal(globalPosition, ignoreOffset)
	tooltip.setText(text)
	return tooltip

func makeTooltipLocalized(globalPosition : Vector2, locID : String, locKey : String = "", ignoreOffset : bool = false) -> Tooltip:
	var tooltip : Tooltip = _makeTooltipInternal(globalPosition, ignoreOffset)
	tooltip.setLocText(locID, locKey)
	return tooltip

func removeTooltip(tooltip : Tooltip, immediate : bool = false) -> void:
	if immediate:
		_showTimers.erase(tooltip)
		tooltip.queue_free()
	else:
		if _showTimers.has(tooltip):
			_hideTimers[tooltip] = (1.0 - _showTimers[tooltip]/SHOW_MAX_TIME) * HIDE_MAX_TIME
			_showTimers.erase(tooltip)
		else:
			_hideTimers[tooltip] = 0.0
