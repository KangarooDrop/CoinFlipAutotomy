extends Node

class_name SealNode

var _sealModel : SealModel = null

@onready var _backgroundSprite : Sprite2D = get_node("%BackgroundSprite2D")
@onready var _sigilSprite : Sprite2D = get_node("%SigilSprite2D")
@onready var popperNode : PopperNode = get_node("%PopperNode")

####################################################################################################

func _attachModel() -> void:
	_sealModel.pop_node.connectSignal(popNode)

func _unattachModel() -> void:
	_sealModel.pop_node.disconnectSignal(popNode)

####################################################################################################

func setModel(newSealModel : SealModel) -> void:
	if self._sealModel != null:
		_unattachModel()
	self._sealModel = newSealModel
	var shaderParamData : Dictionary = Entities.SealBackgroundScript.entityToShaderData(_sealModel.getBackgroundType())
	for paramName : String in shaderParamData.keys():
		_backgroundSprite.material.set_shader_parameter(paramName, shaderParamData[paramName])
	_sigilSprite.texture = _sealModel.getTexture()
	_attachModel()

func getModel() -> SealModel:
	return _sealModel

func popNode() -> void:
	await popperNode.popNode()
