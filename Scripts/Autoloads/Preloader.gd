extends Node

var windowSize : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

const mainMenuPacked : PackedScene = preload("res://Scenes/UI/Menus/MainMenu/MainMenu.tscn")
const characterSelectPacked : PackedScene = preload("res://Scenes/UI/Menus/CharacterSelect/CharacterSelect.tscn")
const venderPacked : PackedScene = preload("res://Scenes/UI/Menus/Vender/Vender.tscn")

const texturePath : String = "res://Textures/"

const venderItemNode : PackedScene = preload("res://Scenes/UI/Menus/Vender/VenderItem.tscn")
const characterPortrait : PackedScene = preload("res://Scenes/UI/Menus/CharacterSelect/CharacterPortrait.tscn")
const sealNode : PackedScene = preload("res://Scenes/Views/SealNode.tscn")
const coinPieceNode : PackedScene = preload("res://Scenes/Views/CoinPieceNode.tscn")
const fingerNode : PackedScene = preload("res://Scenes/Views/FingerNode.tscn")
const ringNode : PackedScene = preload("res://Scenes/Views/RingNode.tscn")

const fingerGibNode : PackedScene = preload("res://Scenes/Match/FingerGib.tscn")

const settingsControlPacked : PackedScene = preload("res://Scenes/UI/Menus/Settings/SettingsControlNode.tscn")

const tooltipPacked : PackedScene = preload("res://Scenes/UI/Tooltip.tscn")

func create(packedScene : PackedScene) -> Node:
	return packedScene.instantiate()
