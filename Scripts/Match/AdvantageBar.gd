extends Control

class_name AdvantageBar

var _matchState : MatchState = null

@onready var leftRect : Control = get_node("%LeftRect")
@onready var playerNumberLabel0 : Label = get_node("%PlayerNumberLabel0")
@onready var popperNode0 : PopperNode = playerNumberLabel0.get_node("PopperNode")
@onready var playerNumberLabel1 : Label = get_node("%PlayerNumberLabel1")
@onready var popperNode1 : PopperNode = playerNumberLabel1.get_node("PopperNode")

const RECT_MIN_SIZE : float = 16.0
const WAIT_MAX_TIME : float = 0.1

####################################################################################################

func _updateBar() -> void:
	var spinUser : int = _matchState.getSpinUser()
	var spinOpponent : int = _matchState.getSpinOpponent()
	
	var compValUser : int = 0
	var compValOpponent : int = 0
	if spinUser > 0:
		compValUser += spinUser
	else:
		compValOpponent += -spinUser
	if spinOpponent > 0:
		compValOpponent += spinOpponent
	else:
		compValUser += -spinOpponent
	
	var percent : float = 0.5
	var total : int = compValUser + compValOpponent
	if total != 0:
		percent = float(compValUser)/total
	
	var totalSize : float = size.x - RECT_MIN_SIZE*2.0
	leftRect.size.x = totalSize * percent + RECT_MIN_SIZE

func _setSpinUser() -> void:
	playerNumberLabel0.text = str(_matchState.getSpinUser())
	playerNumberLabel0.size.x = 0.0
	popperNode0.popNode()
	_updateBar()
	await get_tree().create_timer(WAIT_MAX_TIME).timeout

func _setSpinOpponent() -> void:
	playerNumberLabel1.text = str(_matchState.getSpinOpponent())
	playerNumberLabel1.size.x = 0.0
	popperNode1.popNode()
	_updateBar()
	await get_tree().create_timer(WAIT_MAX_TIME).timeout

func _onSpinChanged(playerModel : PlayerModel) -> void:
	if playerModel == _matchState.getPlayerModelUser():
		await _setSpinUser()
	else:
		await _setSpinOpponent()

func _attachMatchState() -> void:
	_matchState.spin_changed.connectSignal(_onSpinChanged)
	
func _unattachMatchState() -> void:
	_matchState.spin_changed.disconnectSignal(_onSpinChanged)

####################################################################################################

func setMatchState(newMatchState : MatchState) -> void:
	if _matchState != null:
		_unattachMatchState()
	
	_matchState = newMatchState
	_attachMatchState()
	
	_setSpinUser()
	_setSpinOpponent()
