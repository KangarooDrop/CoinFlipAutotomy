extends Serializable

class_name MatchState

#Gameplay variants and constants
const STARTING_SPIN : int = 100
const PREGAME_MAX_TIME : float = 10.0
const TURN_MAX_TIME : float = 999.0
const NUM_TURNS_MAX : int = 20

var roundNumber : int = 0
var pregameStarted : bool = false
var matchStarted : bool = false
var roundStarted : bool = false
var pregameTime : float = 0.0
var currentTurnTime : float = 0.0
var currentTurnNumber : int = 0
var currentTurnsRemaining : int = 0
var activePlayerOnStart : PlayerModel = null
var winnerLastRound : PlayerModel = null
var winningPlayers : Array[PlayerModel] = []
var isActionable : bool = false

var _matchNode : MatchNode = null
var _activePlayer : PlayerModel = null
var _playerModelUser : PlayerModel
var _playerModelOpponent : PlayerModel
var _spinUser : int = STARTING_SPIN
var _spinOpponent : int = STARTING_SPIN
var _additionalTurnQueue : Array = []

var phaseHandler : PhaseHandler = null

var rngQueue : Array[int] = []

#signal spin_changed(playerModel : PlayerModel)
var spin_changed : CFSignal = CFSignal.new(CFSignal.WAIT_TYPE_PARALLEL) #(playerModel : PlayerModel)

####################################################################################################

const FINGER_TARGET_INDEX : int = 0
const COIN_PIECE_TARGET_INDEX : int = 1
func getModelToTargetSerialized(model : RefCounted) -> Array[int]:
	var playerModels : Array[PlayerModel] = [_playerModelUser, _playerModelOpponent]
	for i in range(playerModels.size()):
		var fingerModels : Array[FingerModel] = playerModels[i].getHandModel().getFingers()
		for j in range(fingerModels.size()):
			if model == fingerModels[j] or model == fingerModels[j].getRingModel():
				return [i, FINGER_TARGET_INDEX, j]
		var coinPieceModels : Array[CoinPieceModel] = playerModels[i].getCoinFaceModel().getAllPieces()
		for j in range(coinPieceModels.size()):
			if model == coinPieceModels[j] or model == coinPieceModels[j].getSealModel():
				return [i, COIN_PIECE_TARGET_INDEX, j]
	return []
func getTargetSerializedToModel(data : Array[int]) -> RefCounted:
	var playerModel : PlayerModel = _playerModelUser if data[0]==0 else _playerModelOpponent
	if data[1] == FINGER_TARGET_INDEX:
		return playerModel.getHandModel().getFinger(data[2])
	elif data[1] == COIN_PIECE_TARGET_INDEX:
		return playerModel.getCoinFaceModel().getAllPieces()[data[2]]
	return null
func getTargetSerializedToReadable(data : Array[int]) -> String:
	var rtn : String = ""
	var isUser : bool = data[0] == 0
	var isCoinPiece : bool = data[1] == COIN_PIECE_TARGET_INDEX
	rtn += "Best Target: "
	rtn += "Your " if isUser else "Opponent's "
	rtn += "Coin Piece Socket#" if isCoinPiece else "Finger #"
	rtn += str(data[2])
	return rtn

####################################################################################################

func _setSpinUserInternal(amount : int) -> void:
	_spinUser = amount
	await spin_changed.emitSignal(_playerModelUser)
func _setSpinOpponentInternal(amount : int) -> void:
	_spinOpponent = amount
	await spin_changed.emitSignal(_playerModelOpponent)

####################################################################################################

func _init(data : Dictionary = {}) -> void:
	phaseHandler = PhaseHandler.new()
	phaseHandler.setMatchState(self)
	super._init(data)

func _getPlayerModelToIndex(playerModel : PlayerModel) -> int:
	if playerModel == _playerModelUser:
		return 0
	elif playerModel == _playerModelOpponent:
		return 1
	else:
		return -1
func _getIndexToPlayerModel(index : int) -> PlayerModel:
	if index == 0:
		return _playerModelUser
	elif index == 1:
		return _playerModelOpponent
	else:
		return null

const PLAYER_USER_DATA_KEY : String = "player_user_data"
const PLAYER_OPPONENT_DATA_KEY : String = "player_opponent_data"
const ACTIVE_PLAYER_INDEX_KEY : String = "active_player_index"
const ACTIVE_PLAYER_ON_START_INDEX_KEY : String = "active_player_on_start_index"
const ADDITIONAL_TURN_INDICES_KEY : String = "additional_turn_indices"
const WINNER_LAST_ROUND_INDEX_KEY : String = "winner_last_round_index"
const RNG_QUEUE_KEY : String = "rng_queue"

const SPIN_USER_KEY : String = "spin_user"
const SPIN_OPPONENT_KEY : String = "spin_opponent"
const ROUND_NUMBER_KEY : String = "round_number"
const PREGAME_STARTED_KEY : String = "pregame_started"
const MATCH_STARTED_KEY : String = "match_started"
const ROUND_STARTED_KEY : String = "round_started"
const CURRENT_TURN_NUM_KEY : String = "current_turn_num"
const CURRENT_TURNS_REMAINING_KEY : String = "current_turns_remaining"
const IS_ACTIONABLE_KEY : String = "is_actionable"
const CURRENT_PHASE_KEY : String = "current_phase"

func serialize() -> Dictionary:
	var rtn : Dictionary = super.serialize()
	rtn[PLAYER_USER_DATA_KEY] = _playerModelUser.serialize()
	rtn[PLAYER_OPPONENT_DATA_KEY] = _playerModelOpponent.serialize()
	rtn[ACTIVE_PLAYER_INDEX_KEY] = _getPlayerModelToIndex(_activePlayer)
	rtn[ACTIVE_PLAYER_ON_START_INDEX_KEY] = _getPlayerModelToIndex(activePlayerOnStart)
	rtn[ADDITIONAL_TURN_INDICES_KEY] = []
	for playerModel : PlayerModel in _additionalTurnQueue:
		rtn[ADDITIONAL_TURN_INDICES_KEY].append(_getPlayerModelToIndex(playerModel))
	rtn[WINNER_LAST_ROUND_INDEX_KEY] = _getPlayerModelToIndex(winnerLastRound)
	rtn[RNG_QUEUE_KEY] = rngQueue.duplicate(true)
	
	rtn[SPIN_USER_KEY] = _spinUser
	rtn[SPIN_OPPONENT_KEY] = _spinOpponent
	rtn[ROUND_NUMBER_KEY] = roundNumber
	rtn[PREGAME_STARTED_KEY] = pregameStarted
	rtn[MATCH_STARTED_KEY] = matchStarted
	rtn[ROUND_STARTED_KEY] = roundStarted
	rtn[CURRENT_TURN_NUM_KEY] = currentTurnNumber
	rtn[CURRENT_TURNS_REMAINING_KEY] = currentTurnsRemaining
	rtn[IS_ACTIONABLE_KEY] = isActionable
	rtn[CURRENT_PHASE_KEY] = phaseHandler.currentPhase
	
	return rtn

func deserialize(data : Dictionary) -> Serializable:
	if _playerModelUser == null:
		_playerModelUser = PlayerModel.new(data[PLAYER_USER_DATA_KEY])
	else:
		_playerModelUser.deserialize(data[PLAYER_USER_DATA_KEY])
	if _playerModelOpponent == null:
		_playerModelOpponent = PlayerModel.new(data[PLAYER_OPPONENT_DATA_KEY])
	else:
		_playerModelOpponent.deserialize(data[PLAYER_OPPONENT_DATA_KEY])
	
	_activePlayer = _getIndexToPlayerModel(data[ACTIVE_PLAYER_INDEX_KEY])
	activePlayerOnStart = _getIndexToPlayerModel(data[ACTIVE_PLAYER_ON_START_INDEX_KEY])
	_additionalTurnQueue.clear()
	for index : int in data[ADDITIONAL_TURN_INDICES_KEY]:
		_additionalTurnQueue.append(_getIndexToPlayerModel(index))
	winnerLastRound = _getIndexToPlayerModel(data[WINNER_LAST_ROUND_INDEX_KEY])
	rngQueue = data[RNG_QUEUE_KEY].duplicate()
	
	_spinUser = data[SPIN_USER_KEY]
	_spinOpponent = data[SPIN_OPPONENT_KEY]
	roundNumber = data[ROUND_NUMBER_KEY]
	pregameStarted = data[PREGAME_STARTED_KEY]
	matchStarted = data[MATCH_STARTED_KEY]
	roundStarted = data[ROUND_STARTED_KEY]
	currentTurnNumber = data[CURRENT_TURN_NUM_KEY]
	currentTurnsRemaining = data[CURRENT_TURNS_REMAINING_KEY]
	isActionable = data[IS_ACTIONABLE_KEY]
	phaseHandler.currentPhase = data[CURRENT_PHASE_KEY]
	
	return self

####################################################################################################

func setMatchNode(newMatchNode : MatchNode) -> void:
	_matchNode = newMatchNode

func setPlayerModels(playerModelUser : PlayerModel, playerModelOpponent : PlayerModel) -> void:
	setPlayerModelUser(playerModelUser)
	setPlayerModelOpponent(playerModelOpponent)

func setPlayerModelUser(playerModel : PlayerModel) -> void:
	_playerModelUser = playerModel
	_playerModelUser.resetMatchCoinFaceModel()
	_playerModelUser.resetMatchHandModel()

func setPlayerModelOpponent(playerModel : PlayerModel) -> void:
	_playerModelOpponent = playerModel
	_playerModelOpponent.resetMatchCoinFaceModel()
	_playerModelOpponent.resetMatchHandModel()

func onResetRound() -> void:
	_playerModelUser.resetMatchCoinFaceModel()
	_playerModelOpponent.resetMatchCoinFaceModel()
	_setSpinUserInternal(STARTING_SPIN)
	_setSpinOpponentInternal(STARTING_SPIN)
	pregameTime = PREGAME_MAX_TIME
	pregameStarted = false

func onMatchStart() -> void:
	matchStarted = true
	activePlayerOnStart = _playerModelUser if RNG.getRandi()%2 == 0 else _playerModelOpponent
	await TriggerHandler.onMatchStart(self)

func onRoundStart() -> void:
	roundNumber += 1
	currentTurnNumber = 1
	currentTurnsRemaining = NUM_TURNS_MAX
	await TriggerHandler.onRoundStart(self)
	
	roundStarted = true
	_activePlayer = activePlayerOnStart

func onTurnStart() -> void:
	currentTurnTime = TURN_MAX_TIME
	await TriggerHandler.onTurnStart(self)

func onTurnActionable() -> void:
	isActionable = true

func onTurnEnd() -> void:
	currentTurnNumber += 1
	currentTurnsRemaining -= 1
	await TriggerHandler.onBeforeTurnEnd(self)
	if currentTurnsRemaining > 0:
		if _additionalTurnQueue.size() > 0:
			_activePlayer = _additionalTurnQueue.pop_front()
		else:
			_activePlayer = getOtherPlayerModel(_activePlayer)

func onTurnSkipped() -> void:
	isActionable = false
	await TriggerHandler.onBeforeTurnSkipped(self)

func onRoundEnd() -> void:
	await TriggerHandler.onBeforeRoundEnd(self)
	roundStarted = false
	winnerLastRound = null
	if _spinUser == _spinOpponent:
		winnerLastRound = _playerModelUser if RNG.getRandi() % 2 == 0 else _playerModelOpponent
		#print("EQUAL SPIN: RANDOM WINNER IS ", "" if winnerLastRound == _playerModelUser else "NOT ", "YOU.")
	elif _spinUser > _spinOpponent:
		winnerLastRound = _playerModelUser
		#print("USER IS WINNER")
	else:
		winnerLastRound = _playerModelOpponent
		#print("OPPONENT IS WINNER")
	
	activePlayerOnStart = getOtherPlayerModel(winnerLastRound)
	_activePlayer = null

func onFingerDestroyed() -> void:
	for playerModel : PlayerModel in getAllPlayerModels():
		if playerModel.getHandModel().areAllFingersDestroyed():
			winningPlayers.append(playerModel)
	if winningPlayers.size() == 2:
		print("Match is a draw!")
	elif winningPlayers.size() == 1:
		print("WINNER is ", "OPPONENT!" if winningPlayers[0] == _playerModelOpponent else "YOU!")
	print("MatchState: AAAAAAAAAAAAAA")

####################################################################################################

func isPlayerTurn(playerModel : PlayerModel) -> bool:
	if _activePlayer == null:
		return false
	return playerModel == _activePlayer

func isUserControlled(playerModel : PlayerModel = _activePlayer) -> bool:
	if playerModel == null:
		return false
	return (_playerModelUser == playerModel and playerModel.isHuman) or (not playerModel.isHuman and playerModel.isControlledCPU)

func getAllPlayerModels() -> Array[PlayerModel]:
	var priorityPlayer : PlayerModel = _activePlayer if _activePlayer != null else activePlayerOnStart
	return [priorityPlayer, getOtherPlayerModel(priorityPlayer)]

func getAllTriggerables() -> Array[Triggerable]:
	var rtn : Array[Triggerable] = []
	for playerModel : PlayerModel in getAllPlayerModels():
		rtn.append_array(playerModel.getCoinFaceModel().getAllPieces())
		rtn.append_array(playerModel.getCoinFaceModel().getAllSeals())
		rtn.append_array(playerModel.getHandModel().getRings())
	return rtn

func hasTriggerable(triggerable : Triggerable) -> bool:
	for otherTriggerable : Triggerable in getAllTriggerables():
		if otherTriggerable == triggerable:
			return true
	return false

func getPlayerModelUser() -> PlayerModel: return _playerModelUser
func getPlayerModelOpponent() -> PlayerModel: return _playerModelOpponent
func getActivePlayerModel() -> PlayerModel: return _activePlayer

func getOtherPlayerModel(playerModelFrom : PlayerModel) -> PlayerModel:
	if playerModelFrom == _playerModelUser:
		return _playerModelOpponent
	else:
		return _playerModelUser

func setSpin(playerModel : PlayerModel, amount : int) -> Pointer:
	var originalAmount : int = getSpin(playerModel)
	var amountChangedPointer : Pointer = Pointer.new(amount - originalAmount)
	await TriggerHandler.onBeforeSpinChanged(self, playerModel, amountChangedPointer)
	if playerModel == _playerModelUser:
		await _setSpinUserInternal(originalAmount + amountChangedPointer.val)
	elif playerModel == _playerModelOpponent:
		await _setSpinOpponentInternal(originalAmount + amountChangedPointer.val)
	else:
		push_error("ERROR: Unknown player model given to /setSpinByPlayerModel")
	await TriggerHandler.onAfterSpinChanged(self, playerModel, amountChangedPointer)
	return amountChangedPointer
func setSpinUser(amount : int) -> Pointer:
	return await setSpin(_playerModelUser, amount)
func setSpinOpponent(amount : int) -> Pointer:
	return await setSpin(_playerModelOpponent, amount)

func addSpin(playerModel : PlayerModel, amount : int) -> Pointer:
	return await setSpin(playerModel, getSpin(playerModel) + amount)

func getSpin(playerModel : PlayerModel) -> int:
	if playerModel == _playerModelUser:
		return getSpinUser()
	elif playerModel == _playerModelOpponent:
		return getSpinOpponent()
	else:
		push_error("ERROR: Unknown player model given to /getSpinByPlayerModel")
	return 0
func getSpinUser() -> int: return _spinUser
func getSpinOpponent() -> int: return _spinOpponent

func addAdditionalTurn(playerModel : PlayerModel) -> void:
	_additionalTurnQueue.append(playerModel)

func _targetFuncTrue(_target): return true
func _targetFuncCanActivate(target):
	if not TriggerHandler.canActivateAbilityOfCoinPiece(self, target):
		return false
	if getValidTargets(ModelDB.getAbility(target.abilityScript).targetType, target.getPlayerModel()).size() == 0:
		return false
	return true

func getValidTargets(targetType : Entities.TargetType, playerModel : PlayerModel, verifyCallable : Callable = _targetFuncTrue) -> Array:
	var allTargets : Array[RefCounted] = []
	for currentPlayerModel : PlayerModel in getAllPlayerModels():
		allTargets.append_array(currentPlayerModel.getCoinFaceModel().getAllPieces())
		allTargets.append_array(currentPlayerModel.getHandModel().getFingers())
		allTargets.append_array(currentPlayerModel.getHandModel().getRings())
	for i in range(allTargets.size()-1, -1, -1):
		if not Entities.TargetScript.isValidModel(targetType, playerModel, allTargets[i]) or not verifyCallable.call(allTargets[i]):
			allTargets.remove_at(i)
	return allTargets

func getCoinPiecesThatCanActivate(playerModel : PlayerModel) -> Array[CoinPieceModel]:
	var allCoinPieces : Array[CoinPieceModel] = []
	allCoinPieces.append_array(getValidTargets(Entities.TargetType.ABILITY_PIECE_FRIENDLY, playerModel, _targetFuncCanActivate))
	for i in range(allCoinPieces.size()-1, -1, -1):
		var abilitySingleton : Ability = ModelDB.getAbility(allCoinPieces[i].abilityScript)
		if getValidTargets(abilitySingleton.targetType, playerModel).size() == 0:
			allCoinPieces.remove_at(i)
			continue
	return allCoinPieces

func getTargetCoinPieceCanActivate(playerModel : PlayerModel) -> CoinPieceModel:
	return await getTarget(Entities.TargetType.ABILITY_PIECE_FRIENDLY, playerModel, _targetFuncCanActivate)

func getTarget(targetType : Entities.TargetType, playerModel : PlayerModel, verifyCallable : Callable = _targetFuncTrue) -> Variant:
	var target : RefCounted = null
	if _matchNode != null:
		if isUserControlled(playerModel):
			while target == null or not Entities.TargetScript.isValidModel(targetType, playerModel, target) or not verifyCallable.call(target):
				target = await _matchNode.getTarget(targetType, playerModel, verifyCallable)
				if target == null:
					break
		else:
			target = await _matchNode.getTargetCPU(targetType, playerModel, verifyCallable)
	else:
		var validTargets : Array = getValidTargets(targetType, playerModel, verifyCallable)
		if validTargets.size() != 0:
			target = validTargets[RNG.getRandi() % validTargets.size()]
	if target != null and target.has_method("popNode"):
		target.popNode()
	return target

func onTriggerActivated() -> void:
	if _matchNode != null:
		_matchNode.onTriggerActivated()

func onBeforeTriggerCondition() -> void:
	pass

func onAfterTriggerCondition() -> void:
	pass

func activateAbilityScript(abilityScript : Script, context : AbilityContext) -> void:
	var ability : Ability = ModelDB.getAbility(abilityScript)
	await TriggerHandler.onBeforeAbilityCheck(self, ability, context)
	if context.isCountered:
		await TriggerHandler.onBeforeAbilityCountered(self, ability, context)
	if not context.isCountered:
		await TriggerHandler.onBeforeAbilityActivated(self, ability, context)
		await ability.activate(self, context)
		await TriggerHandler.onAfterAbilityActivated(self, ability, context)
	else:
		await TriggerHandler.onAfterAbilityCountered(self, ability, context)

func activateAbilityScriptFromSource(abilityScript : Script, source : Variant, isCopy : bool = false) -> bool:
	var targetType : Entities.TargetType = ModelDB.getAbilitySingleton(abilityScript).targetType
	var context : AbilityContext = null
	if targetType == Entities.TargetType.NONE:
		context = AbilityContext.new(source, [])
	else:
		var target = await getTarget(targetType, source.getPlayerModel())
		if target == null:
			return false
		context = AbilityContext.new(source, [target])
	context.isCopy = isCopy
	isActionable = false
	await activateAbilityScript(abilityScript, context)
	return true

func activateAbilityOfCoinPieceModel(coinPieceModel : CoinPieceModel, isCopy : bool = false) -> bool:
	if coinPieceModel == null:
		return false
	if not hasTriggerable(coinPieceModel):
		push_error("ERROR: Could not find Coin Piece Model given to /activateAbilityOfCoinPieceModel")
		return false
	if coinPieceModel.abilityScript == null:
		return false
	return await activateAbilityScriptFromSource(coinPieceModel.abilityScript, coinPieceModel, isCopy)

func activateAbilityByCoinFaceIndex(coinFaceModel : CoinFaceModel, socketIndex : Entities.CoinPieceSocketIndex, isCopy : bool = false) -> bool:
	var coinPieceModel : CoinPieceModel = coinFaceModel.getCoinPieceAtSocket(socketIndex)
	if coinPieceModel == null:
		return false
	return await activateAbilityOfCoinPieceModel(coinPieceModel, isCopy)
