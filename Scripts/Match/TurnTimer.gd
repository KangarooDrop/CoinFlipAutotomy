extends Control

class_name TurnTimer

const POP_ANGLE_MAX : float = PI/8.0
const POP_SCALE_MAX : float = 1.25
const POP_TIME_MAX : float = 0.25

var popRotationTween : Tween = null
var popScaleTween : Tween = null

var _currentTime : int = -1

@onready var turnTimerLabel : Label = get_node("%TurnTimerLabel")

func _resetPopTween() -> void:
	if popRotationTween:
		popRotationTween.kill()
	if popScaleTween:
		popScaleTween.kill()
	
	popScaleTween = get_tree().create_tween().bind_node(self)
	popScaleTween.tween_property(turnTimerLabel, "scale", Vector2.ONE * POP_SCALE_MAX, POP_TIME_MAX/2.0)
	popScaleTween.tween_property(turnTimerLabel, "scale", Vector2.ONE, POP_TIME_MAX/2.0)
	
	popRotationTween = get_tree().create_tween().bind_node(self)
	popRotationTween.tween_property(turnTimerLabel, "rotation", -POP_ANGLE_MAX, POP_TIME_MAX/4.0)
	popRotationTween.tween_property(turnTimerLabel, "rotation", POP_ANGLE_MAX, POP_TIME_MAX/2.0)
	popRotationTween.tween_property(turnTimerLabel, "rotation", 0.0, POP_TIME_MAX/4.0)

func setTime(val : int) -> void:
	turnTimerLabel.text = str(val)
	_resetPopTween()
	_currentTime = val

func getTime() -> int:
	return _currentTime
