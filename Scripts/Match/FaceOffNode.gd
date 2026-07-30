extends Control

class_name FaceOffNode

const START_WAIT_TIME : float = 0.5
const RAMMING_INITIAL_TIME : float = 0.5
const RAMMING_INITIAL_ROTATION : float = PI/16.0
const REBOUND_TIME : float = 0.25
const REBOUND_DIST : float = 128.0
const REBOUND_ROTATION : float = RAMMING_INITIAL_ROTATION/2.0
const PUSH_NUM_PUSHES_EACH : int = 2
const PUSH_MAX_DIST : float = REBOUND_DIST/8.0
const PUSH_TIME : float = 0.375
const NAMEPLATE_REVEAL_TIME : float = 0.5
const VS_REVEAL_TIME : float = 0.25
const CLASH_WAIT_TO_HIDE_TIME : float = 4.0
const CLASH_HIDE_TIME : float = 0.5

const WINNER_SHOW_TIME : float = 0.5
const WINNER_CLASH_WAIT_TIME : float = 0.5
const WINNER_RAM_DIST : float = 128.0
const WINNER_RAM_TIME : float = 1.0
const WINNER_WINDUP_RATIO : float = 0.75
const WINNER_END_DIST : float = 512.0
const WINNER_KNOCK_TIME : float = 0.5
const WINNER_SPLASH_END_Y : float = 32.0
const WINNER_SPLASH_TIME : float = 1.0
const WINNER_FINISH_WAIT_TIME : float = 3.0

var _userDemon : DemonModel = null
var _opponentDemon : DemonModel = null

@onready var poseHBox : HBoxContainer = get_node("%PoseHBox")
@onready var poseBuffer : Control = get_node("%PoseBuffer")

@onready var vsHolder : Control = get_node("%VSHolder")
@onready var nameplateHolderUser : Control = get_node("%NameplateHolderUser")
@onready var poseScalerUser : Node2D = get_node("%PoseScalerUser")
@onready var poseRectUser : TextureRect = get_node("%PoseRectUser")
@onready var nameLabelUser : Label = get_node("%NameLabelUser")
@onready var epithetLabelUser : Label = get_node("%EpithetLabelUser")

@onready var nameplateHolderOpponent : Control = get_node("%NameplateHolderOpponent")
@onready var poseScalerOpponent : Node2D = get_node("%PoseScalerOpponent")
@onready var poseRectOpponent : TextureRect = get_node("%PoseRectOpponent")
@onready var nameLabelOpponent : Label = get_node("%NameLabelOpponent")
@onready var epithetLabelOpponent : Label = get_node("%EpithetLabelOpponent")
@onready var winnerSplashLabel : Label = get_node("%WinnerSplashLabel")

@onready var initialPoseHBoxPos : Vector2 = poseHBox.position
@onready var initialPoseBufferMinSize : Vector2 = poseBuffer.custom_minimum_size
@onready var initialWinnerSplashLabelPos : Vector2 = winnerSplashLabel.position

signal clash_finished()
signal winner_finished()

func _resetClash() -> void:
	poseScalerUser.rotation = -RAMMING_INITIAL_ROTATION
	poseScalerOpponent.rotation = RAMMING_INITIAL_ROTATION
	nameplateHolderUser.modulate.a = 0.0
	nameplateHolderOpponent.modulate.a = 0.0
	vsHolder.modulate.a = 0.0

func _showRam(tween : Tween = null) -> Tween:
	if tween == null:
		tween = get_tree().create_tween().bind_node(self)
	#Wait before clash starts
	tween.tween_interval(START_WAIT_TIME)
	#Initial hit
	tween.tween_property(poseBuffer, "custom_minimum_size", Vector2.ZERO, RAMMING_INITIAL_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseScalerUser, "rotation", 0.0, RAMMING_INITIAL_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseScalerOpponent, "rotation", 0.0, RAMMING_INITIAL_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	#Recoil from initial hit
	tween.tween_property(poseBuffer, "custom_minimum_size", Vector2(REBOUND_DIST, 0.0), REBOUND_TIME/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseScalerUser, "rotation", -REBOUND_ROTATION, REBOUND_TIME/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseScalerOpponent, "rotation", REBOUND_ROTATION, REBOUND_TIME/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	#Return to clash point
	tween.tween_property(poseBuffer, "custom_minimum_size", Vector2.ZERO, REBOUND_TIME/2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseScalerUser, "rotation", 0.0, REBOUND_TIME/2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseScalerOpponent, "rotation", 0.0, REBOUND_TIME/2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	return tween

func _finishClash(tween : Tween) -> Tween:
	#Show nameplates
	tween.tween_callback(_onShowNameplates)
	#Fight wobble back and forth
	for i in range(PUSH_NUM_PUSHES_EACH):
		tween.tween_property(poseHBox, "position", initialPoseHBoxPos + Vector2.LEFT*PUSH_MAX_DIST*randf(), PUSH_TIME/(2.0 * PUSH_NUM_PUSHES_EACH)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(poseHBox, "position", initialPoseHBoxPos + Vector2.RIGHT*PUSH_MAX_DIST*randf(), PUSH_TIME/(2.0 * PUSH_NUM_PUSHES_EACH)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(poseHBox, "position", initialPoseHBoxPos, PUSH_TIME/(2.0 * PUSH_NUM_PUSHES_EACH)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	#Wait before hiding
	tween.tween_interval(CLASH_WAIT_TO_HIDE_TIME)
	#Fade away to reveal match
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), CLASH_HIDE_TIME)
	tween.parallel().tween_property(poseBuffer, "custom_minimum_size", initialPoseBufferMinSize, RAMMING_INITIAL_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	return tween

func _onShowNameplates() -> Tween:
	var tween : Tween = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween.tween_property(nameplateHolderUser, "modulate", Color(1.0, 1.0, 1.0, 1.0), NAMEPLATE_REVEAL_TIME)
	tween.tween_property(nameplateHolderOpponent, "modulate", Color(1.0, 1.0, 1.0, 1.0), NAMEPLATE_REVEAL_TIME)
	tween.chain()
	tween.tween_property(vsHolder, "modulate", Color(1.0, 1.0, 1.0, 1.0), VS_REVEAL_TIME)
	return tween

func _showWinnerSplash() -> void:
	var tween : Tween = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween.tween_property(winnerSplashLabel, "position", Vector2(initialWinnerSplashLabelPos.x, WINNER_SPLASH_END_Y), WINNER_SPLASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(winnerSplashLabel, "modulate", Color(1.0, 1.0, 1.0, 1.0), WINNER_SPLASH_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.chain()

func _finishWinner(tween : Tween, isUser : bool) -> Tween:
	#Pull back before ram
	tween.tween_property(poseBuffer, "custom_minimum_size", Vector2(WINNER_RAM_DIST, initialPoseBufferMinSize.y), WINNER_RAM_TIME * WINNER_WINDUP_RATIO).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseHBox, "position", initialPoseHBoxPos + Vector2(-1.0 if isUser else 1.0, 0.0) * WINNER_RAM_DIST/2.0, WINNER_RAM_TIME * WINNER_WINDUP_RATIO).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	#Move toward loser quickly
	tween.tween_property(poseBuffer, "custom_minimum_size", Vector2.ZERO, WINNER_RAM_TIME * (1.0-WINNER_WINDUP_RATIO)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseHBox, "position", initialPoseHBoxPos, WINNER_RAM_TIME * (1.0 - WINNER_WINDUP_RATIO)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	#Show winner splash text
	tween.tween_callback(_showWinnerSplash)
	#Knock loser aside and move to center
	tween.tween_property(poseBuffer, "custom_minimum_size", Vector2(WINNER_END_DIST, initialPoseBufferMinSize.y), WINNER_KNOCK_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(poseHBox, "position", initialPoseHBoxPos + Vector2(1.0 if isUser else -1.0, 0.0) * (WINNER_END_DIST/2.0 + 196.0/2.0), WINNER_KNOCK_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.chain()
	#Wait before ending anim
	tween.tween_interval(WINNER_FINISH_WAIT_TIME)
	
	return tween

func _onTweenClashFinished() -> void:
	print("Faceoff: Clash Finished")
	clash_finished.emit()
	hide()

func _onTweenWinnerFinished() -> void:
	print("Faceoff: Winner Finished")
	winner_finished.emit()
	hide()

####################################################################################################

func setUser(demon : DemonModel) -> void:
	poseRectUser.texture = demon.poseTexture
	nameLabelUser.text = demon.getName()
	epithetLabelUser.text = demon.getEpithet()
	_userDemon = demon

func setOpponent(demon : DemonModel) -> void:
	poseRectOpponent.texture = demon.poseTexture
	nameLabelOpponent.text = demon.getName()
	epithetLabelOpponent.text = demon.getEpithet()
	_opponentDemon = demon

func showClash() -> void:
	show()
	_resetClash()
	if modulate.a < 1.0:
		modulate.a = 1.0
	var tween : Tween = _showRam()
	_finishClash(tween)
	tween.tween_callback(_onTweenClashFinished)

func showWinner(isUser : bool) -> void:
	show()
	winnerSplashLabel.text = _userDemon.getWinSplash() if isUser else _opponentDemon.getWinSplash()
	_resetClash()
	var tween : Tween = get_tree().bind_node(self).create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), WINNER_SHOW_TIME)
	tween.tween_interval(WINNER_CLASH_WAIT_TIME)
	_showRam(tween)
	_finishWinner(tween, isUser)
	tween.tween_callback(_onTweenWinnerFinished)
