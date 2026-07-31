extends Node
class_name PopperNode

var _rotationTween : Tween = null
var _scaleTween : Tween = null

@export var popAngleMax : float = PI/8.0
@export var popScaleMax : float = 1.25
@export var popTimeMax : float = 0.25

signal finished()

func popNode() -> Signal:
	if _rotationTween:
		_rotationTween.kill()
	if _scaleTween:
		_scaleTween.kill()
	var parentNode : Node = get_parent()
	
	_scaleTween = get_tree().create_tween().bind_node(self)
	_scaleTween.tween_property(parentNode, "scale", Vector2.ONE * popScaleMax, popTimeMax/2.0)
	_scaleTween.tween_property(parentNode, "scale", Vector2.ONE, popTimeMax/2.0)
	
	_rotationTween = get_tree().create_tween().bind_node(self)
	_rotationTween.tween_property(parentNode, "rotation", -popAngleMax, popTimeMax/4.0)
	_rotationTween.tween_property(parentNode, "rotation", popAngleMax, popTimeMax/2.0)
	_rotationTween.tween_property(parentNode, "rotation", 0.0, popTimeMax/4.0)
	
	_rotationTween.tween_callback(func():
		finished.emit()
	)
	
	return finished
