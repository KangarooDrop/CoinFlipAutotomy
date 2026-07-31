extends RefCounted

class_name MatchState

#Gameplay variants and constants
const STARTING_SPIN : int = 100
const TURN_MAX_TIME : float = 10.0
const NUM_TURNS_MAX : int = 20

var roundNumber : int = 0
var matchStarted : bool = false
var roundStarted : bool = false
var currentTurnTime : float = 0.0
var currentTurnNumber : int = 0
var currentTurnsRemaining : int = 0
var activePlayerOnStart : PlayerModel = null
var winnerLastRound : PlayerModel = null
var isActionable : bool = false

var _isDebug : bool = true
var _activePlayer : PlayerModel = null
var _playerModelUser : PlayerModel
var _playerModelOpponent : PlayerModel
var _spinUser : int = STARTING_SPIN
var _spinOpponent : int = STARTING_SPIN
var _additionalTurnQueue : Array = []

signal spin_changed(playerModel : PlayerModel)

####################################################################################################

func _setSpinUserInternal(amount : int) -> void:
	_spinUser = amount
	spin_changed.emit(_playerModelUser)
func _setSpinOpponentInternal(amount : int) -> void:
	_spinOpponent = amount
	spin_changed.emit(_playerModelOpponent)

####################################################################################################

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
	isActionable = true

func onTurnEnd() -> void:
	currentTurnNumber += 1
	currentTurnsRemaining -= 1
	isActionable = false
	await TriggerHandler.onBeforeTurnEnd(self)
	if currentTurnsRemaining > 0:
		if _additionalTurnQueue.size() > 0:
			_activePlayer = _additionalTurnQueue.pop_front()
		else:
			_activePlayer = getOtherPlayerModel(_activePlayer)

func onTurnSkipped() -> void:
	await TriggerHandler.onBeforeTurnSkipped(self)

func onRoundEnd() -> void:
	await TriggerHandler.onBeforeRoundEnd(self)
	roundStarted = false
	winnerLastRound = null
	if _spinUser == _spinOpponent:
		winnerLastRound = _playerModelUser if RNG.getRandi() % 2 == 0 else _playerModelOpponent
		print("EQUAL SPIN: RANDOM WINNER IS ", "" if winnerLastRound == _playerModelUser else "NOT ", "YOU.")
	elif _spinUser > _spinOpponent:
		winnerLastRound = _playerModelUser
		print("USER IS WINNER")
	else:
		winnerLastRound = _playerModelOpponent
		print("OPPONENT IS WINNER")
	
	activePlayerOnStart = getOtherPlayerModel(winnerLastRound)
	_activePlayer = null

func onFingerDestroyed() -> void:
	var deadPlayers : Array = []
	for playerModel : PlayerModel in getAllPlayerModels():
		if playerModel.getHandModel().areAllFingersDestroyed():
			deadPlayers.append(playerModel)
	if deadPlayers.size() == 2:
		print("Match is a draw!")
	elif deadPlayers.size() == 1:
		print("WINNER is ", "YOU!" if deadPlayers[0] == _playerModelOpponent else "OPPONENT!")
	print("MatchState: AAAAAAAAAAAAAA")

func activateAbilityScript(abilityScript : Script, context : AbilityContext) -> void:
	isActionable = false
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

####################################################################################################

func isPlayerTurn(playerModel : PlayerModel) -> bool:
	if _activePlayer == null:
		return false
	return playerModel == _activePlayer

func isMyTurn() -> bool:
	if _activePlayer == null:
		return false
	if _isDebug:
		return true
	return isPlayerTurn(_playerModelUser)

func getAllPlayerModels() -> Array[PlayerModel]:
	var priorityPlayer : PlayerModel = _activePlayer if _activePlayer != null else activePlayerOnStart
	return [priorityPlayer, getOtherPlayerModel(priorityPlayer)]

func getAllTriggerables() -> Array[Triggerable]:
	var rtn : Array[Triggerable] = []
	for playerModel : PlayerModel in getAllPlayerModels():
		rtn.append_array(playerModel.getCoinFaceModel().getAllPieces())
		rtn.append_array(playerModel.getCoinFaceModel().getAllSeals())
		rtn.append_array(playerModel.getHandModel().getFingerRings())
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
		_setSpinUserInternal(originalAmount + amountChangedPointer.val)
	elif playerModel == _playerModelOpponent:
		_setSpinOpponentInternal(originalAmount + amountChangedPointer.val)
	else:
		push_error("ERROR: Unknown player model given to /setSpinByPlayerModel")
	await TriggerHandler.onAfterSpinChanged(self, playerModel)
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
