extends Control

class_name CharacterPortrait

const HOVER_SCALE_INC : float = 0.1
const HOVER_TIME_TO_MAX : float = 0.125
const WIDTH : float = 160.0

var demon : DemonModel = null

var selected : bool = false
var hovering : bool = false
var hoverTimer : float = 0.0

@onready var portraitRect : TextureRect = get_node("%PortraitRect")
@onready var nameLabel : RichTextLabel = get_node("%NameLabel")
@onready var scalerNode : Node2D = get_node("%ScalerNode")

signal pressed()

func setDemon(newDemon : DemonModel) -> void:
	self.demon = newDemon
	portraitRect.texture = demon.portraitTexture
	nameLabel.text = demon.getName()
	nameLabel.size.x = 0.0
	nameLabel.position.x = -nameLabel.size.x/2.0

func onMouseEnter() -> void:
	hovering = true
	mouse_entered.emit()

func onMouseExit() -> void:
	hovering = false
	mouse_exited.emit()

func onPressed() -> void:
	pressed.emit()

func _process(delta: float) -> void:
	if hovering and not selected and hoverTimer < HOVER_TIME_TO_MAX:
		hoverTimer = min(HOVER_TIME_TO_MAX, hoverTimer + delta)
	elif (not hovering or selected) and hoverTimer > 0.0:
		hoverTimer = max(0.0, hoverTimer - delta)
	
	var hoverScale : float = lerp(0.0, HOVER_SCALE_INC, hoverTimer/HOVER_TIME_TO_MAX)
	scalerNode.scale = Vector2.ONE * (1.0 + hoverScale)
