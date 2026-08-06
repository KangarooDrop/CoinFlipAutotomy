extends Node

class_name VenderItem

const IDLE_PERIOD : float = 16.0
const IDLE_ROT_MAX : float = PI/32.0
const IDLE_SCALE_MAX : float = 1.1
const IDLE_SCALE_MIN : float = 1.0

const HOVER_SCALE_INC : float = 0.2
const HOVER_TIME_TO_MAX : float = 0.125

enum ITEM_TYPE {RING, COIN_PIECE_CORE, COIN_PIECE_EXTERIOR}

var itemModel : ItemModel = null
var idleTimer : float = randf() * IDLE_PERIOD
var hovering : bool = false
var hoverTimer : float = 0.0

@onready var sprite : Sprite2D = get_node("%Sprite2D")
@onready var tooltipViewer : TooltipViewer = get_node("%TooltipViewer")

signal hover_entered()
signal hover_exited()
signal button_down()
signal button_up()
signal pressed()

func onHoverEnter() -> void:
	hovering = true
	hover_entered.emit()

func onHoverExited() -> void:
	hovering = false
	hover_exited.emit()

func onButtonDown() -> void:
	button_down.emit()

func onButtonUp() -> void:
	button_up.emit()

func onPressed() -> void:
	pressed.emit()

func setItem(item : ItemModel) -> void:
	if item is RingModel:
		setRing(item)
	else:
		setCoinPiece(item)
	itemModel = item

func setRing(ringModel : RingModel) -> void:
	sprite.texture = ringModel.getTextureAtlas()
	sprite.region_rect.size = Vector2.ONE * 32.0
	tooltipViewer.setLocalizedModel(ringModel)

func setCoinPiece(coinPiece : CoinPieceModel) -> void:
	sprite.texture = coinPiece.getTextureAtlas()
	sprite.region_rect.size = Vector2.ONE * 64.0
	tooltipViewer.setLocalizedModel(coinPiece)

func _process(delta: float) -> void:
	idleTimer += delta
	if hovering and hoverTimer < HOVER_TIME_TO_MAX:
		hoverTimer = min(HOVER_TIME_TO_MAX, hoverTimer + delta)
	elif not hovering and hoverTimer > 0.0:
		hoverTimer = max(0.0, hoverTimer - delta)
	
	var xs : float = sin(idleTimer * PI*2.0/IDLE_PERIOD)
	var xr : float = sin(idleTimer * 2.0 * PI*2.0/IDLE_PERIOD)
	var hoverScale : float = lerp(0.0, HOVER_SCALE_INC, hoverTimer/HOVER_TIME_TO_MAX)
	sprite.scale = Vector2.ONE * lerp(IDLE_SCALE_MIN + hoverScale, IDLE_SCALE_MAX + hoverScale, xs)
	sprite.rotation = lerp(-IDLE_ROT_MAX, IDLE_ROT_MAX, xr)
