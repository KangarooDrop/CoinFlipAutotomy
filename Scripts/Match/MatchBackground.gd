extends Node

class_name MatchBackground

var bgScale : float = 1.0
@export var isTurning : bool = true

var tweenScale : Tween = null

@onready var _backgroundHolder : Node2D = get_node("%BackgroundHolder")
@onready var _offsetHolder : Control = get_node("%CenterControl")
@onready var _originalOffset : Vector2 = _offsetHolder.position

const BG_SCALE_MIN : float = 0.125
const BG_SCALE_MAX : float = 1.0
const BG_TURN_RATE : float = PI/32.0

func setOffset(offset : Vector2) -> void:
	_offsetHolder.position = _originalOffset + offset

func setRotation(amount : float) -> void:
	_backgroundHolder.rotation = amount

func setScale(amount : float) -> void:
	amount = min(BG_SCALE_MAX, max(BG_SCALE_MIN, amount))
	_backgroundHolder.scale = Vector2.ONE * amount

func lerpScale(amount : float, duration : float, easeType : Tween.EaseType = Tween.EASE_IN_OUT, transType : Tween.TransitionType = Tween.TRANS_QUAD) -> void:
	amount = min(BG_SCALE_MAX, max(BG_SCALE_MIN, amount))
	if tweenScale:
		tweenScale.kill()
	tweenScale = get_tree().create_tween().bind_node(self).set_ease(easeType).set_trans(transType)
	tweenScale.tween_property(_backgroundHolder, "scale", Vector2.ONE * amount, duration)

func _process(delta: float) -> void:
	if isTurning:
		setRotation(_backgroundHolder.rotation + delta * BG_TURN_RATE)
