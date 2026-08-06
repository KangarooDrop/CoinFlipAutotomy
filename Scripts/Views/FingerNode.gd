extends Node2D

class_name FingerNode

var _fingerModel : FingerModel = null
var _ringNode : RingNode = null

var _ringPosition : Vector2 = Vector2.ZERO
var _ringRotation : float = 0.0

@onready var sprite : Sprite2D = get_node("%Sprite2D")
@onready var ringHolder : Node2D = get_node("%RingHolder")

func setHandData(handModel : HandModel, flipH : bool, index : int) -> void:
	var ringRotData : RingRotData = handModel.getRotData()[index]
	_ringPosition = ringRotData.getOffset(flipH)
	_ringRotation = ringRotData.getRotation(flipH)
	sprite.flip_h = flipH
	sprite.texture = handModel.getTextureAtlas()
	sprite.region_rect.position.y = sprite.region_rect.size.x * (2+index)

func _attachModel() -> void:
	_fingerModel.ring_added.connect(onRingModelAdded)
	_fingerModel.ring_removed.connect(onRingModelRemoved)
	_fingerModel.ring_replaced.connect(onRingModelReplaced)
	_fingerModel.after_finger_destroyed.connect(onFingerDestroyed)

func _unattachModel() -> void:
	_fingerModel.ring_added.disconnect(onRingModelAdded)
	_fingerModel.ring_removed.disconnect(onRingModelRemoved)
	_fingerModel.ring_replaced.disconnect(onRingModelReplaced)
	_fingerModel.after_finger_destroyed.disconnect(onFingerDestroyed)

func setModel(newFingerModel : FingerModel):
	if _fingerModel != null:
		_unattachModel()
	_fingerModel = newFingerModel
	_attachModel()
	var newRingModel : RingModel = _fingerModel.getRingModel()
	if newRingModel != null:
		onRingModelAdded(newRingModel)

func onRingModelAdded(ringModel : RingModel) -> RingNode:
	var ringNode : RingNode = CmdFinger.getModelToNode(ringModel)
	if ringNode == null:
		ringNode = CmdFinger.createRingNode(ringModel, ringHolder)
		ringNode.position = _ringPosition
		ringNode.sprite.rotation = _ringRotation
	return onRingNodeAdded(ringNode)

func onRingNodeAdded(ringNode : RingNode) -> RingNode:
	var rtn : RingNode = onRingModelRemoved()
	
	var parentNode : Node = ringNode.get_parent()
	if is_instance_valid(parentNode) and parentNode != ringHolder:
		parentNode.remove_child(ringNode)
	if parentNode != ringHolder:
		ringHolder.add_child(ringNode)
	_ringNode = ringNode
	return rtn

func onRingModelRemoved() -> RingNode:
	var oldRingNode : RingNode = _ringNode
	_ringNode = null
	return oldRingNode

func onRingModelReplaced(newRingModel : RingModel, _oldRingModel : RingModel) -> RingNode:
	var oldRingNode : RingNode = onRingModelRemoved()
	_ringNode = onRingModelAdded(newRingModel)
	return oldRingNode

func onFingerDestroyed() -> RingNode:
	var oldRingNode : RingNode = onRingModelRemoved()
	CmdFinger.createGib(self)
	hide()
	return oldRingNode

func getRingNode() -> RingNode:
	return _ringNode

func hasPointLocal(point : Vector2) -> bool:
	if point.x < 0 or point.y < 0 or point.x >= sprite.region_rect.size.x or point.y >= sprite.region_rect.size.y:
		return false
	if sprite.flip_h:
		point.x = sprite.region_rect.size.x-1 - point.x
	return sprite.texture.get_image().get_pixel(Util.betterFloor(point.x + sprite.region_rect.position.x), Util.betterFloor(point.y + sprite.region_rect.position.y)).a > 0

func hasPointGlobal(point : Vector2) -> bool:
	return hasPointLocal(point - global_position)

var _mouseHovering : bool = false
func setMouseHovering(val : bool) -> void:
	_mouseHovering = val

func isMouseHovering() -> bool:
	return _mouseHovering

func getModel() -> FingerModel:
	return _fingerModel
