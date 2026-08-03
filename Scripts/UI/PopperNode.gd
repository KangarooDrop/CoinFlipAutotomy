extends Node
class_name PopperNode

var _rotationTween : Tween = null
var _scaleTween : Tween = null

var _originalRotation : float = 0.0
var _originalScale : Vector2 = Vector2.ONE

@export var popAngleMax : float = PI/8.0
@export var popScaleMax : float = 1.25
@export var popTimeMax : float = 0.35
@export var popWaitMax : float = 0.15

signal finished()

func popNode() -> Signal:
	var parentNode : Node = get_parent()
	
	if _rotationTween:
		_rotationTween.kill()
		parentNode.rotation = _originalRotation
	if _scaleTween:
		_scaleTween.kill()
		parentNode.scale = _originalScale
	
	_originalRotation = parentNode.rotation
	_originalScale = parentNode.scale
	
	_rotationTween = get_tree().create_tween().bind_node(self)
	_rotationTween.tween_property(parentNode, "rotation", _originalRotation-popAngleMax, popTimeMax/4.0)
	_rotationTween.tween_property(parentNode, "rotation", _originalRotation+popAngleMax, popTimeMax/2.0)
	_rotationTween.tween_property(parentNode, "rotation", _originalRotation, popTimeMax/4.0)
	
	_scaleTween = get_tree().create_tween().bind_node(self)
	_scaleTween.tween_property(parentNode, "scale", _originalScale * popScaleMax, popTimeMax/2.0)
	_scaleTween.tween_property(parentNode, "scale", _originalScale, popTimeMax/2.0)
	
	_rotationTween.tween_callback(func():
		await get_tree().create_timer(popWaitMax).timeout
		finished.emit()
	)
	
	return finished
