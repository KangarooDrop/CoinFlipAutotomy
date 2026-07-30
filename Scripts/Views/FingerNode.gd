extends Node2D

class_name FingerNode

var _fingerModel : FingerModel = null
var _fingerRingNode : FingerRingNode = null

var _ringPosition : Vector2 = Vector2.ZERO
var _ringRotation : float = 0.0

@onready var sprite : Sprite2D = get_node("%Sprite2D")
@onready var ringHolder : Node2D = get_node("%RingHolder")

func setHandData(handModel : HandModel, flipH : bool, index : int) -> void:
	var ringRotData : FingerRingRotData = handModel.getRotData()[index]
	_ringPosition = ringRotData.getOffset(flipH)
	_ringRotation = ringRotData.getRotation(flipH)
	sprite.flip_h = flipH
	sprite.texture = handModel.getTextureAtlas()
	sprite.region_rect.position.y = sprite.region_rect.size.x * (2+index)

func _attachModel() -> void:
	_fingerModel.ring_added.connect(onFingerRingModelAdded)
	_fingerModel.ring_removed.connect(onFingerRingModelRemoved)
	_fingerModel.ring_replaced.connect(onFingerRingModelReplaced)
	_fingerModel.after_finger_destroyed.connect(onFingerDestroyed)

func _unattachModel() -> void:
	_fingerModel.ring_added.disconnect(onFingerRingModelAdded)
	_fingerModel.ring_removed.disconnect(onFingerRingModelRemoved)
	_fingerModel.ring_replaced.disconnect(onFingerRingModelReplaced)
	_fingerModel.after_finger_destroyed.disconnect(onFingerDestroyed)

func setModel(newFingerModel : FingerModel):
	if _fingerModel != null:
		_unattachModel()
	_fingerModel = newFingerModel
	_attachModel()
	var newFingerRingModel : FingerRingModel = _fingerModel.getFingerRingModel()
	if newFingerRingModel != null:
		onFingerRingModelAdded(newFingerRingModel)

func onFingerRingModelAdded(fingerRingModel : FingerRingModel) -> FingerRingNode:
	var fingerRingNode : FingerRingNode = CmdFinger.getModelToNode(fingerRingModel)
	if fingerRingNode == null:
		fingerRingNode = CmdFinger.createFingerRingNode(fingerRingModel, ringHolder)
		fingerRingNode.position = _ringPosition
		fingerRingNode.sprite.rotation = _ringRotation
	return onFingerRingNodeAdded(fingerRingNode)

func onFingerRingNodeAdded(fingerRingNode : FingerRingNode) -> FingerRingNode:
	var rtn : FingerRingNode = onFingerRingModelRemoved()
	
	var parentNode : Node = fingerRingNode.get_parent()
	if is_instance_valid(parentNode) and parentNode != ringHolder:
		parentNode.remove_child(fingerRingNode)
	if parentNode != ringHolder:
		ringHolder.add_child(fingerRingNode)
	_fingerRingNode = fingerRingNode
	return rtn

func onFingerRingModelRemoved() -> FingerRingNode:
	var oldFingerRingNode : FingerRingNode = _fingerRingNode
	_fingerRingNode = null
	return oldFingerRingNode

func onFingerRingModelReplaced(newFingerRingModel : FingerRingModel, _oldFingerRingModel : FingerRingModel) -> FingerRingNode:
	var oldFingerRingNode : FingerRingNode = onFingerRingModelRemoved()
	_fingerRingNode = onFingerRingModelAdded(newFingerRingModel)
	return oldFingerRingNode

func onFingerDestroyed() -> FingerRingNode:
	var oldFingerRingNode : FingerRingNode = onFingerRingModelRemoved()
	CmdFinger.createGib(self)
	hide()
	return oldFingerRingNode

func getFingerRingNode() -> FingerRingNode:
	return _fingerRingNode

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
