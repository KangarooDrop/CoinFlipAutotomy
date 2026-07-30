extends Node2D

class_name HandNode

var _handModel : HandModel = null

var _fingerNodes : Array[FingerNode] = []

@export var flipH : bool = false

@onready var spriteHolder : Node2D = get_node("%SpriteHolder")
@onready var spriteNubs : Sprite2D = get_node("%SpriteNubs")

@onready var ringHolder : Node2D = get_node("%RingHolder")
@onready var gibHolder : Node2D = get_node("%GibHolder")

####################################################################################################

func _ready() -> void:
	if flipH:
		spriteNubs.flip_h = true

func _setNumFingers(numFingers : int) -> void:
	for fingerNode : FingerNode in _fingerNodes:
		fingerNode.name += "_OLD"
		fingerNode.queue_free()
	_fingerNodes.clear()
	for i in range(numFingers):
		var fingerNode : FingerNode = Preloader.fingerNode.instantiate()
		spriteHolder.add_child(fingerNode)
		_fingerNodes.append(fingerNode)

func _attachModel() -> void:
	pass

func _unattachModel() -> void:
	pass

func _clear() -> void:
	if _handModel == null:
		return
	_unattachModel()
	_setNumFingers(0)
	_handModel = null

####################################################################################################

func getNumFingers() -> int:
	return _handModel.getRotData().size()

func setHandModel(newHandModel : HandModel) -> void:
	if newHandModel == _handModel:
		return
	_clear()
	_handModel = newHandModel
	_attachModel()
	spriteNubs.texture = _handModel.getTextureAtlas()
	_setNumFingers(getNumFingers())
	
	for i in range(_handModel.getNumFingers()):
		_fingerNodes[i].setHandData(_handModel, flipH, i)
		_fingerNodes[i].setModel(_handModel.getFinger(i))

func getModel() -> HandModel:
	return _handModel

func getAllFingerNodes() -> Array[FingerNode]:
	return _fingerNodes

func getAllFingerRingNodes() -> Array[FingerRingNode]:
	var rtn : Array[FingerRingNode] = []
	for i in range(_fingerNodes.size()):
		var fingerRingNode : FingerRingNode = _fingerNodes[i].getFingerRingNode()
		if fingerRingNode != null:
			rtn.append(fingerRingNode)
	return rtn

func onControlGUIInput(event: InputEvent = null) -> void:
	if event is InputEventMouseMotion or event == null:
		var mousePos : Vector2 = get_local_mouse_position() + spriteNubs.region_rect.size/2.0
		for fingerNode : FingerNode in _fingerNodes:
			fingerNode.setMouseHovering(fingerNode.hasPointLocal(mousePos))
