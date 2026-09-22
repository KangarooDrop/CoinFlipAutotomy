extends Control

const NUM_OPTIONS : int = 3
const OFFSET_PER_PORTRAIT : float = CharacterPortrait.WIDTH + 16.0

const INFO_HIDE_PORTRAITS_MAX_TIME : float = 0.2
const INFO_SHOW_DETAILS_MAX_TIME : float = 0.2
const INFO_PORTRAIT_SELECTED_OFFSET : Vector2 = Vector2(-64.0, -48.0)
const INFO_PORTRAIT_HIDDEN_OFFSET : float = 400.0
const INFO_HAND_OFFSET : float = 128.0
const INFO_POSE_OFFSET : float = 240.0 + 32.0
const INFO_BUTTON_OFFSET : float = 128.0

var characterPortraits : Array[CharacterPortrait] = []

var waitingForTweens : bool = false
var selectedIndex : int = -1

@onready var portraitHolder : Control = get_node("%PortraitHolder")
@onready var gearHolder : GearHolder = get_node("%GearHolder")
@onready var handNode : HandNode = gearHolder.handNode
@onready var coinFaceNode : CoinFaceNode = gearHolder.coinFaceNode
@onready var poseHolder : Control = get_node("%PoseHolder")
@onready var poseWindow : Control = get_node("%PoseWindow")
@onready var poseSprite : Sprite2D = get_node("%PoseSprite")
@onready var buttonHolder : Control = get_node("%ButtonHolder")

@onready var buttonOriginalYPosition : float = buttonHolder.position.y
@onready var poseOriginalXPosition : float = poseHolder.position.x
@onready var poseOffset : float = poseWindow.size.x

signal character_selected(demon : DemonModel)

func _ready() -> void:
	buttonHolder.position.y = buttonOriginalYPosition + INFO_BUTTON_OFFSET
	
	for portrait : Node in characterPortraits:
		portrait.queue_free()
	characterPortraits.clear()
	
	var optionTypes : Array[Script] = [DemonLust, DemonSloth, DemonWrath]
	optionTypes.append_array(ModelDB.getRandomDemonScriptsNoRepeat(NUM_OPTIONS - optionTypes.size(), optionTypes))
	
	for i in range(optionTypes.size()):
		var portParent : Control = Control.new()
		portParent.size = Vector2.ZERO
		portraitHolder.add_child(portParent)
		var portrait : CharacterPortrait = Preloader.characterPortrait.instantiate()
		portParent.add_child(portrait)
		portrait.setDemon(ModelDB.getDemon(optionTypes[i]))
		portrait.pressed.connect(self.onPortraitPressed.bind(portrait))
		characterPortraits.append(portrait)
	
	for i in range(characterPortraits.size()):
		characterPortraits[i].get_parent().position.x = getPortraitX(i)

func getPortraitX(index : int) -> float:
	var offsetIndex : float = -(characterPortraits.size()-1)/2.0 + index
	return offsetIndex * OFFSET_PER_PORTRAIT

func _onWaitFinished() -> void:
	waitingForTweens = false

func onPortraitPressed(pressedPortrait : CharacterPortrait) -> void:
	if waitingForTweens:
		return
	waitingForTweens = true
	selectedIndex = characterPortraits.find(pressedPortrait)
	setDemonData()
	characterPortraits[selectedIndex].selected = true
	characterPortraits[selectedIndex].onMouseExit()
	
	for i in range(characterPortraits.size()):
		var charPort : CharacterPortrait = characterPortraits[i]
		if i != selectedIndex:
			var moveDir : int = sign(i-selectedIndex)
			var unselectedTween : Tween = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			unselectedTween.tween_property(charPort, "position", Vector2(moveDir * INFO_PORTRAIT_HIDDEN_OFFSET, 0.0), INFO_HIDE_PORTRAITS_MAX_TIME)
	
	await get_tree().create_timer(INFO_HIDE_PORTRAITS_MAX_TIME).timeout
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).tween_property(pressedPortrait.get_parent(), "position", INFO_PORTRAIT_SELECTED_OFFSET, INFO_SHOW_DETAILS_MAX_TIME)
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).tween_property(gearHolder, "position", Vector2(0.0, 0.0), INFO_SHOW_DETAILS_MAX_TIME)
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).tween_property(poseWindow, "position", Vector2(-INFO_POSE_OFFSET, 0.0), INFO_SHOW_DETAILS_MAX_TIME)
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).tween_property(buttonHolder, "position", Vector2(0.0, 0.0), INFO_SHOW_DETAILS_MAX_TIME)
	
	var waitTween : Tween = get_tree().create_tween().bind_node(self)
	waitTween.tween_interval(INFO_SHOW_DETAILS_MAX_TIME)
	waitTween.tween_callback(_onWaitFinished)

func onBackPressed() -> void:
	if waitingForTweens:
		return
	waitingForTweens = true
	
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).tween_property(characterPortraits[selectedIndex].get_parent(), "position", Vector2(getPortraitX(selectedIndex), 0.0), INFO_SHOW_DETAILS_MAX_TIME)
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).tween_property(gearHolder, "position", Vector2(-INFO_HAND_OFFSET, 0.0), INFO_SHOW_DETAILS_MAX_TIME)
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).tween_property(poseWindow, "position", Vector2(0.0, 0.0), INFO_SHOW_DETAILS_MAX_TIME)
	get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).tween_property(buttonHolder, "position", Vector2(0.0, INFO_BUTTON_OFFSET), INFO_SHOW_DETAILS_MAX_TIME)
	
	await get_tree().create_timer(INFO_SHOW_DETAILS_MAX_TIME).timeout
	for i in range(characterPortraits.size()):
		if i != selectedIndex:
			get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).tween_property(characterPortraits[i], "position", Vector2.ZERO, INFO_HIDE_PORTRAITS_MAX_TIME)
	
	var waitTween : Tween = get_tree().create_tween().bind_node(self)
	waitTween.tween_interval(INFO_HIDE_PORTRAITS_MAX_TIME)
	waitTween.tween_callback(_onWaitFinished)
	
	await get_tree().create_timer(INFO_HIDE_PORTRAITS_MAX_TIME).timeout
	characterPortraits[selectedIndex].selected = false
	selectedIndex = -1
	#Triggers a mouse motion event for Control.mouse_entered signals of portraits
	var viewportScaleVec2 : Vector2 = Vector2((get_viewport() as Window).size) / get_viewport_rect().size
	var viewportScale : float = min(viewportScaleVec2.x, viewportScaleVec2.y)
	Input.warp_mouse(get_viewport().get_mouse_position() * viewportScale)

func onPlayPressed() -> void:
	if waitingForTweens:
		return
	RunManager.onCharacterChosen(characterPortraits[selectedIndex].demon.get_script())

func setDemonData() -> void:
	var starterData : StarterData = characterPortraits[selectedIndex].demon.getStarterData()
	handNode.setHandModel(starterData.createHandModel())
	coinFaceNode.setModel(starterData.createCoinFaceModel())
	poseSprite.texture = characterPortraits[selectedIndex].demon.poseTexture
