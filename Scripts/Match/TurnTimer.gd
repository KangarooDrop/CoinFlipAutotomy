extends Control

class_name TurnTimer

var _currentTime : int = -1

@onready var turnTimerLabel : Label = get_node("%TurnTimerLabel")
@onready var popperNode : PopperNode = get_node("%PopperNode")

func setTime(val : int) -> void:
	turnTimerLabel.text = str(val)
	popperNode.popNode()
	_currentTime = val

func getTime() -> int:
	return _currentTime
