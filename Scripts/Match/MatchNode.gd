extends Node2D

class_name MatchNode

var _matchState : MatchState

var _flippingCoinToNextPlayer : bool = false

const GEAR_SHOW_MAX_TIME : float = 0.5
const BG_SCALE_UPDATE_DURATION : float = 1.0

@onready var faceOffNode : FaceOffNode = get_node("%FaceOffNode")
@onready var background : MatchBackground = get_node("%MatchBackground")
@onready var advantageBar : AdvantageBar = get_node("%AdvantageBar")
@onready var turnTimer : TurnTimer = get_node("%TurnTimer")
@onready var coinNode : CoinNode = get_node("%CoinNode")

@onready var gearHolderUser : Control = get_node("%GearHolderUser")
@onready var handNodeUser : HandNode = gearHolderUser.get_node("HandNode")
@onready var coinFaceNodeUser : CoinFaceNode = gearHolderUser.get_node("CoinFaceNode")

@onready var gearHolderOpponent : Control = get_node("%GearHolderOpponent")
@onready var handNodeOpponent : HandNode = gearHolderOpponent.get_node("HandNode")
@onready var coinFaceNodeOpponent : CoinFaceNode = gearHolderOpponent.get_node("CoinFaceNode")

@onready var invalidTargetsOverlay : Node2D = get_node("%InvalidTargetsOverlay")

@onready var opponentGearEndPosX : float = gearHolderOpponent.position.x

####################################################################################################

####################################################################################################

func _ready() -> void:
	_initMatch()

func _initMatch():
	_matchState = MatchState.new()
	advantageBar.setMatchState(_matchState)
	gearHolderUser.position.x = -gearHolderUser.size.x
	gearHolderOpponent.position.x = opponentGearEndPosX+gearHolderOpponent.size.x
	
	background.setScale(MatchBackground.BG_SCALE_MAX)
	faceOffNode.showClash()
	await faceOffNode.clash_finished
	
	_showGearUser()
	_showGearOpponent()
	
	_onMatchStartInternal()

func _attachPlayerModel(playerModel : PlayerModel, isUser : bool) -> void:
	pass

func _unattachPlayerModel(playerModel : PlayerModel, isUser : bool) -> void:
	pass

func _showGearUser() -> void:
	get_tree().create_tween().bind_node(self).tween_property(gearHolderUser, "position", Vector2(0.0, gearHolderUser.position.y), GEAR_SHOW_MAX_TIME)

func _hideGearUser() -> void:
	get_tree().create_tween().bind_node(self).tween_property(gearHolderUser, "position", Vector2(-gearHolderUser.size.x, gearHolderUser.position.y), GEAR_SHOW_MAX_TIME)

func _showGearOpponent() -> void:
	get_tree().create_tween().bind_node(self).tween_property(gearHolderOpponent, "position", Vector2(opponentGearEndPosX, gearHolderOpponent.position.y), GEAR_SHOW_MAX_TIME)

func _hideGearOpponent() -> void:
	get_tree().create_tween().bind_node(self).tween_property(gearHolderOpponent, "position", Vector2(opponentGearEndPosX+gearHolderOpponent.size.x, gearHolderOpponent.position.y), GEAR_SHOW_MAX_TIME)

func _updateBackgroundScale(duration : float = BG_SCALE_UPDATE_DURATION) -> void:
	var t : float = 1.0
	if _matchState.roundStarted:
		t = min(1.0, float(_matchState.currentTurnsRemaining)/MatchState.NUM_TURNS_MAX)
	t = pow(t, 0.125)
	background.lerpScale(lerp(MatchBackground.BG_SCALE_MAX, MatchBackground.BG_SCALE_MIN, t), duration)

func _process(delta: float) -> void:
	if not _matchState.roundStarted:
		return
	if _flippingCoinToNextPlayer:
		return
	if _matchState.currentTurnTime <= 0.0:
		return
	if not _matchState.isActionable:
		return
	
	if _matchState.currentTurnTime > 0.0:
		_matchState.currentTurnTime -= delta
		var ceilVal : int = Util.betterFloor(_matchState.currentTurnTime)
		if ceilVal != turnTimer.getTime():
			turnTimer.setTime(ceilVal)
		if _matchState.currentTurnTime <= 0.0:
			_onTurnSkippedInternal()

func _onMatchStartInternal() -> void:
	await _matchState.onMatchStart()
	background.isTurning = true
	_onResetRoundInternal()

func _onResetRoundInternal() -> void:
	await _matchState.onResetRound()
	
	var playerModelUser : PlayerModel = _matchState.getPlayerModelUser()
	handNodeUser.setHandModel(playerModelUser.getHandModel())
	coinFaceNodeUser.setModel(playerModelUser.getCoinFaceModel())
	coinNode.setCoinFaceModelUser(playerModelUser.getCoinFaceModel())
	
	var playerModelOpponent : PlayerModel = _matchState.getPlayerModelOpponent()
	handNodeOpponent.setHandModel(playerModelOpponent.getHandModel())
	coinFaceNodeOpponent.setModel(playerModelOpponent.getCoinFaceModel())
	coinNode.setCoinFaceModelOpponent(playerModelOpponent.getCoinFaceModel())
	
	if _matchState.winnerLastRound == null:
		coinNode.setObverseModel(coinFaceNodeUser.getModel())
	else:
		coinNode.setObverseModel(_matchState.winnerLastRound.getCoinFaceModel())
	
	_onRoundStartInternal()

func _onRoundStartInternal() -> void:
	_updateBackgroundScale(1.0)
	await coinNode.rapidFlip(_matchState.activePlayerOnStart.getCoinFaceModel(), 1.0)
	await get_tree().create_timer(5.0).timeout
	await _matchState.onRoundStart()
	_onTurnStartInternal()

func _onTurnStartInternal() -> void:
	await _matchState.onTurnStart()
	_updateBackgroundScale()

func _onTurnEndInternal() -> void:
	if choosingTarget:
		_cancelAbilityTarget()
	
	await _matchState.onTurnEnd()
	
	if _matchState.currentTurnsRemaining > 0:
		_flippingCoinToNextPlayer = true
		await coinNode.flipToModel(_matchState.getActivePlayerModel().getCoinFaceModel())
		_flippingCoinToNextPlayer = false
		_onTurnStartInternal()
	else:
		_onRoundEndInternal()

func _onTurnSkippedInternal() -> void:
	await _matchState.onTurnSkipped()
	_onTurnEndInternal()

func _onRoundEndInternal() -> void:
	_matchState.onRoundEnd()
	
	coinNode.rapidFlip(_matchState.winnerLastRound.getCoinFaceModel())
	background.isTurning = false
	var numBounces : int = 3
	var t : float = CoinNode.RAPID_FLIP_DURATION/(2.0*numBounces)
	background.lerpScale(MatchBackground.BG_SCALE_MAX, t, Tween.EaseType.EASE_IN)
	await get_tree().create_timer(t).timeout
	for i in range(numBounces):
		background.lerpScale(lerp(MatchBackground.BG_SCALE_MAX, MatchBackground.BG_SCALE_MIN, 0.25 * float(numBounces-i)/numBounces), t, Tween.EaseType.EASE_OUT)
		await get_tree().create_timer(t).timeout
		background.lerpScale(MatchBackground.BG_SCALE_MAX, t, Tween.EaseType.EASE_IN)
		await get_tree().create_timer(t).timeout
	await get_tree().create_timer(2.0).timeout
	
	var fingerToDestroy : FingerModel = await _getFingerToDestroyInternal(_matchState.winnerLastRound)
	CmdFinger.destroyFinger(fingerToDestroy)
	
	background.isTurning = true
	_onResetRoundInternal()

####################################################################################################

func _userActivateAbility(coinPieceModel : CoinPieceModel) -> void:
	canCancelTargetChoice = true
	var successfullyActivated : bool = await activateAbilityOfCoinPieceModel(coinPieceModel)
	canCancelTargetChoice = false
	if successfullyActivated:
		await _onTurnEndInternal()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not _matchState.isMyTurn():
				return
			if choosingTarget and canCancelTargetChoice:
				_cancelAbilityTarget()
				return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if not _matchState.isMyTurn() and not choosingTarget:
				return
			for coinPieceNode : CoinPieceNode in getAllCoinPieceNodes():
				if coinPieceNode.tooltipViewer.isMouseHovering():
					if choosingTarget:
						target_node_chosen_or_forced_skip.emit(coinPieceNode)
					elif _matchState.getActivePlayerModel().getCoinFaceModel().hasCoinPieceModel(coinPieceNode.getModel()):
						_userActivateAbility(coinPieceNode.getModel())
					return
			if not choosingTarget:
				return
			for fingerRingNode : FingerRingNode in getAllFingerRingNodes():
				if fingerRingNode.tooltipViewer.isMouseHovering():
					target_node_chosen_or_forced_skip.emit(fingerRingNode)
					return
			if not choosingTarget:
				return
			for fingerNode : FingerNode in getAllFingerNodes():
				if fingerNode.isMouseHovering():
					target_node_chosen_or_forced_skip.emit(fingerNode)
					return

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if choosingTarget and canCancelTargetChoice and _matchState.isMyTurn():
			_cancelAbilityTarget()
		else:
			print("ESCAPING")
		return
	
	if not _matchState.isMyTurn():
		return
	if event.is_action_pressed("skip"):
		_onTurnSkippedInternal()
		return
	for i in range(1, 10):
		if event.is_action_pressed("action_" + str(i)):
			_userActivateAbility(_matchState.getActivePlayerModel().getCoinFaceModel().getCoinPieceAtSocket(i-1))
			return

####################################################################################################

func getAllCoinPieceNodes() -> Array[CoinPieceNode]:
	return coinFaceNodeUser.getAllCoinPieceNodes() + coinFaceNodeOpponent.getAllCoinPieceNodes() + coinNode.getAllCoinPieceNodes()
func getAllFingerRingNodes() -> Array[FingerRingNode]:
	return handNodeUser.getAllFingerRingNodes() + handNodeOpponent.getAllFingerRingNodes()
func getAllFingerNodes() -> Array[FingerNode]:
	return handNodeUser.getAllFingerNodes() + handNodeOpponent.getAllFingerNodes()

func setPlayerModels(playerModelUser : PlayerModel, playerModelOpponent : PlayerModel) -> void:
	setPlayerModelUser(playerModelUser)
	setPlayerModelOpponent(playerModelOpponent)

func setPlayerModelUser(playerModel : PlayerModel) -> void:
	if _matchState.getPlayerModelUser() != null:
		_unattachPlayerModel(_matchState.getPlayerModelUser(), true)
	_matchState.setPlayerModelUser(playerModel)
	_attachPlayerModel(playerModel, true)
	
	handNodeUser.setHandModel(playerModel.getHandModel())
	coinFaceNodeUser.setModel(playerModel.getCoinFaceModel())
	faceOffNode.setUser(playerModel.getDemon())
	coinNode.setCoinFaceModelUser(playerModel.getCoinFaceModel())

func setPlayerModelOpponent(playerModel : PlayerModel) -> void:
	if _matchState.getPlayerModelOpponent() != null:
		_unattachPlayerModel(_matchState.getPlayerModelOpponent(), false)
	_matchState.setPlayerModelOpponent(playerModel)
	_attachPlayerModel(playerModel, false)
	
	handNodeOpponent.setHandModel(playerModel.getHandModel())
	coinFaceNodeOpponent.setModel(playerModel.getCoinFaceModel())
	faceOffNode.setOpponent(playerModel.getDemon())
	coinNode.setCoinFaceModelOpponent(playerModel.getCoinFaceModel())

func getMatchState() -> MatchState:
	return _matchState

################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################

func skipTurn() -> void:
	await _onTurnSkippedInternal()

func activateAbilityScript(abilityScript : Script, source : Variant) -> bool:
	var targetType : Entities.AbilityTargetType = ModelDB.getAbilitySingleton(abilityScript).targetType
	var context : AbilityContext = null
	if targetType == Entities.AbilityTargetType.NONE:
		context = AbilityContext.new(source, [])
	else:
		var target = await getAbilityTarget(targetType, source.getPlayerModel())
		if target == null:
			return false
		context = AbilityContext.new(source, [target])
	await _matchState.activateAbilityScript(abilityScript, context)
	return true

func activateAbilityOfCoinPieceModel(coinPieceModel : CoinPieceModel) -> bool:
	if not _matchState.hasTriggerable(coinPieceModel):
		push_error("ERROR: Could not find Coin Piece Model given to /activateAbilityOfCoinPieceModel")
		return false
	if coinPieceModel.abilityScript == null:
		return false
	return await activateAbilityScript(coinPieceModel.abilityScript, coinPieceModel)

func activateAbilityByCoinFaceIndex(coinFaceModel : CoinFaceModel, socketIndex : Entities.CoinPieceSocketIndex) -> bool:
	var coinPieceModel : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(socketIndex)
	if coinPieceModel == null:
		return false
	return await activateAbilityOfCoinPieceModel(coinPieceModel)

func getAbilityTarget(abilityTargetType : Entities.AbilityTargetType, playerModel : PlayerModel) -> Variant:
	return await _getAbilityTargetInternal(abilityTargetType, playerModel)

signal target_node_chosen_or_forced_skip
var choosingTarget : bool = false
var canCancelTargetChoice : bool = false
func isValidTargetNode(abilityTargetType : Entities.AbilityTargetType, playerModel : PlayerModel, targetNode : Variant) -> bool:
	#Targets a coin piece and the target is a coin piece node
	if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.COIN_PIECE) and targetNode is CoinPieceNode:
		if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.ANY):
			return true
		elif (playerModel == targetNode.getModel().getPlayerModel()) == Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FRIENDLY):
			return true
	#Targets a seal and the target is a coin piece node
	if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.SEAL) and targetNode is CoinPieceNode and targetNode.getModel().getSealModel() != null:
		#If targets not friendly or target is friendly
		if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.ANY):
			return true
		elif playerModel.getCoinFaceModel().getAllPieces().has(targetNode.getModel()) == Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FRIENDLY):
			return true
	#Targets a non-seal coin piece
	if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.NON_SEAL) and targetNode is CoinPieceNode and targetNode.getModel().getSealModel() == null:
		#If targets not friendly or target is friendly
		if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.ANY):
			return true
		elif playerModel.getCoinFaceModel().getAllPieces().has(targetNode.getModel()) == Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FRIENDLY):
			return true
	#Targets a finger ring and the target is a finger ring node
	if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FINGER_RING) and targetNode is FingerRingNode:
		if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.ANY):
			return true
		elif playerModel.getHandModel().getFingerRings().has(targetNode.getModel()) == Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FRIENDLY):
			return true
	#Targets a finger and the target is a finger node
	if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FINGER) and targetNode is FingerNode:
		if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.ANY):
			return true
		elif playerModel.getHandModel().getFingers().has(targetNode.getModel()) == Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FRIENDLY):
			return true
	#Targets a finger and the target is a finger ring node
	if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FINGER) and targetNode is FingerRingNode:
		if Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.ANY):
			return true
		elif (playerModel == targetNode.getModel().getPlayerModel()) == Util.hasBitVal(abilityTargetType, Entities.AbilityTargetType.FRIENDLY):
			return true
	return false

func getTargetNodeToModel(node : Node, targetType : Entities.AbilityTargetType) -> Variant:
	if Util.hasBitVal(targetType, Entities.AbilityTargetType.SEAL) and node is CoinPieceNode:
		return node.getModel().getSealModel()
	elif Util.hasBitVal(targetType, Entities.AbilityTargetType.FINGER) and node is FingerRingNode:
		return node.getModel().getFingerModel()
	else:
		return node.getModel()

func _getAbilityTargetInternal(abilityTargetType : Entities.AbilityTargetType, playerModel : PlayerModel) -> Variant:
	var targetNode = null
	choosingTarget = true
	invalidTargetsOverlay.show()
	_setTargetingZIndices(abilityTargetType, playerModel)
	while targetNode == null or not isValidTargetNode(abilityTargetType, playerModel, targetNode):
		targetNode = await target_node_chosen_or_forced_skip
		if targetNode == null:
			break
	choosingTarget = false
	canCancelTargetChoice = false
	_resetTargetingZIndices()
	return getTargetNodeToModel(targetNode, abilityTargetType) if targetNode != null else targetNode
func _setTargetingZIndices(abilityTargetType : Entities.AbilityTargetType, playerModel : PlayerModel) -> void:
	var targetableNodes : Array = coinFaceNodeUser.getAllCoinPieceNodes() + coinFaceNodeOpponent.getAllCoinPieceNodes() + coinNode.getAllCoinPieceNodes() \
			+ handNodeUser.getAllFingerRingNodes() + handNodeOpponent.getAllFingerRingNodes() + handNodeUser.getAllFingerNodes() + handNodeOpponent.getAllFingerNodes()
	for targetNode : Node2D in targetableNodes:
		targetNode.z_index = 2 if isValidTargetNode(abilityTargetType, playerModel, targetNode) else 0
func _resetTargetingZIndices() -> void:
	invalidTargetsOverlay.hide()
	

func _getFingerToDestroyInternal(playerModel : PlayerModel) -> FingerModel:
	var targetNode = null
	var targetType : Entities.AbilityTargetType = Entities.AbilityTargetType.FINGER_FRIENDLY
	choosingTarget = true
	invalidTargetsOverlay.show()
	_setTargetingZIndices(targetType, playerModel)
	while targetNode == null or not isValidTargetNode(targetType, playerModel, targetNode):
		targetNode = await target_node_chosen_or_forced_skip
	choosingTarget = false
	_resetTargetingZIndices()
	return getTargetNodeToModel(targetNode, targetType)

func _cancelAbilityTarget() -> void:
	target_node_chosen_or_forced_skip.emit(null)
