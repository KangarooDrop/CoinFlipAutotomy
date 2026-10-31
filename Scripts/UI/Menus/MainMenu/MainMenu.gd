extends Node

@onready var coinNode : CoinNode = get_node("%CoinNode")
@onready var coinHolder : Control = get_node("%CoinHolder")
@onready var matchBackground : MatchBackground = get_node("%MatchBackground")

const COIN_NODE_FLIP_TIME_MAX : float = 2.0
const COIN_NODE_FLIP_WAIT : float = 1.0

func _ready() -> void:
	matchBackground.setOffset(Vector2.DOWN * 32.0)
	matchBackground.setScale(lerp(matchBackground.BG_SCALE_MIN, matchBackground.BG_SCALE_MAX, 0.0675))
	
	var demonTypes : Array[Script] = ModelDB.getRandomDemonScriptsNoRepeat(2)
	var coinFaceModelObverse : CoinFaceModel = ModelDB.getDemonSingleton(demonTypes[0]).getStarterData().createCoinFaceModel()
	var coinFaceModelReverse : CoinFaceModel = ModelDB.getDemonSingleton(demonTypes[1]).getStarterData().createCoinFaceModel()
	
	"""
	var coinPieceTypes : Array = [CPCounterweightCore, 
								CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior, 
								CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior, CPCounterweightExterior]
	var coinFaceModelObverse : CoinFaceModel = CoinFaceModel.new()
	for coinPieceType : Script in coinPieceTypes:
		coinFaceModelObverse.addCoinPieceToNextSocket(ModelDB.getCoinPiece(coinPieceType))
	var coinFaceModelReverse : CoinFaceModel = CoinFaceModel.new()
	for coinPieceType : Script in coinPieceTypes:
		coinFaceModelReverse.addCoinPieceToNextSocket(ModelDB.getCoinPiece(coinPieceType))
	"""
	
	coinNode.setCoinFaceModelUser(coinFaceModelObverse)
	coinNode.setCoinFaceModelOpponent(coinFaceModelReverse)
	coinNode.setObverseModel(coinFaceModelObverse)
	await coinNode.getCoinFaceModelToNode(coinFaceModelObverse).playLockInAnim(0.25)
	onCoinNodeFlipFinished()
	
	#c.rapidFlip(coinFaceModelObverse, 100.0, 0.5, 100)
	
	"""
	var counterweightCore : CPCounterweightCore = ModelDB.getCoinPiece(CPCounterweightCore)
	print(counterweightCore.getLocID() + ".name")
	Localization.setLanguage("spa")
	print(Localization.getLocalizedData(counterweightCore.getLocDataRaw("name")))
	Localization.setLanguage("eng")
	"""

func onCoinNodeFlipFinished() -> void:
	await get_tree().create_timer(COIN_NODE_FLIP_WAIT).timeout
	coinNode.flipToOther(COIN_NODE_FLIP_TIME_MAX).connect(onCoinNodeFlipFinished)

func onPlayPressed() -> void:
	get_tree().change_scene_to_packed(Preloader.characterSelectPacked)

func onSettingsPressed() -> void:
	Settings.showSettings()

func onExitPressed() -> void:
	get_tree().quit()

####################################################################################################

func _getRandomPlayerModel() -> PlayerModel:
	var demonScript : Script = ModelDB.getRandomDemonScript()
	var handModel : HandModel = HandModel.new()
	handModel.setDemonScript(demonScript)
	for i in range(handModel.getTotalNumFingers()):
		handModel.addRing(ModelDB.getRing(ModelDB.getRandomRingScript()))
	var coinFaceModel : CoinFaceModel = CoinFaceModel.new()
	for i in range(9):
		var abilityScript = null
		if i == 0:
			abilityScript = ModelDB.getRandomAbilityCoreScript()
		else:
			abilityScript = ModelDB.getRandomAbilityExteriorScript()
		coinFaceModel.addCoinPieceToNextSocket(CoinPieceModel.new().setAbilityScript(abilityScript))
	return PlayerModel.new().setHandModel(handModel).setCoinFaceModel(coinFaceModel)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed() and not event.is_echo():
		var matchState : MatchState = MatchState.new()
		var playerModelUser : PlayerModel = _getRandomPlayerModel()
		var playerModelOpponent : PlayerModel = _getRandomPlayerModel()
		matchState.setPlayerModels(playerModelUser, playerModelOpponent)
		var serialized : Dictionary = matchState.serialize()
		
		var deserialized : MatchState = MatchState.new().deserialize(serialized)
		print(serialized == deserialized.serialize())
		
		return
		checkRNGDecision()
		return
		checkDecisionSpeed()

func checkDecisionSpeed() -> void:
	var matchState : MatchState = MatchState.new()
	var playerModelUser : PlayerModel = _getRandomPlayerModel()
	var playerModelOpponent : PlayerModel = _getRandomPlayerModel()
	matchState.setPlayerModels(playerModelUser, playerModelOpponent)
	
	
	var usecs : int = Time.get_ticks_usec()
	var n : int = 1000
	for i in range(n):
		var data : Dictionary = matchState.serialize()
		var decision : MatchStateDecision = MatchStateDecision.new()
		decision.deserialize(data)
	print("Finised ", n, " match state clones in ", (Time.get_ticks_usec() - usecs)/1_000_000.0, " seconds.")
	Tracker.printTimes()
	Tracker.clear()

func onStartRNGAccumulator() -> void:
	pass
func onEndRNGAccumulator() -> void:
	pass

func checkRNGDecision() -> void:
	RNG.start_rng_accumulator.connectSignal(onStartRNGAccumulator)
	RNG.end_rng_accumulator.connectSignal(onEndRNGAccumulator)
	
	var rngChoicesTwoNumbers : Array = ["0", "1"]
	var rngChoicesThreeNumbers : Array = ["0", "1", "2"]
	var rngChoicesOneLetters : Array = ["A"]
	var rngChoicesTwoLetters : Array = ["A", "B"]
	var rngChoicesTwoLetters2 : Array = ["X", "Y"]
	var rngChoicesThreeLetters : Array = ["A", "B", "C"]
	var rngChoicesTenLetters : Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
	
	#1 Deep
	simRNG(func(source):
		var rtn : Array = []
		rtn.append(RNG.select(null, rngChoicesThreeNumbers, source))
		return rtn
	, ["0", "1", "2", null])
	
	#2 Deep
	simRNG(func(source):
		var rtn : Array = []
		rtn.append(RNG.select(null, rngChoicesThreeNumbers, source))
		rtn.append(RNG.select(null, rngChoicesThreeLetters, source))
		return rtn
	, ["0", "A", "0", "B", "0", "C", "1", "A", "1", "B", "1", "C", "2", "A", "2", "B", "2", "C", null, null])
	
	#3 Deep
	var expectedOut : Array = []
	for a in rngChoicesThreeNumbers:
		for b in rngChoicesThreeNumbers:
			for c in rngChoicesThreeNumbers:
				expectedOut.append_array([a, b, c])
	for i in range(3):
		expectedOut.append(null)
	simRNG(func(source):
		var rtn : Array = []
		rtn.append(RNG.select(null, rngChoicesThreeNumbers, source))
		rtn.append(RNG.select(null, rngChoicesThreeNumbers, source))
		rtn.append(RNG.select(null, rngChoicesThreeNumbers, source))
		return rtn
	, expectedOut)
	
	#Conditional 3/3 Left
	simRNG(func(source):
		var rtn : Array = []
		var out = RNG.select(null, rngChoicesThreeNumbers, source)
		rtn.append(out)
		if out == rngChoicesThreeNumbers[0]:
			rtn.append(RNG.select(null, rngChoicesThreeLetters, source))
		return rtn
	, ["0", "A", "0", "B", "0", "C", "1", "2", null])
	
	#Conditional 3/3 Middle
	simRNG(func(source):
		var rtn : Array = []
		var out = RNG.select(null, rngChoicesThreeNumbers, source)
		rtn.append(out)
		if out == rngChoicesThreeNumbers[1]:
			rtn.append(RNG.select(null, rngChoicesThreeLetters, source))
		return rtn
	, ["0", "1", "A", "1", "B", "1", "C", "2", null])
	
	#Conditional 3/3 Right
	simRNG(func(source):
		var rtn : Array = []
		var out = RNG.select(null, rngChoicesThreeNumbers, source)
		rtn.append(out)
		if out == rngChoicesThreeNumbers[2]:
			rtn.append(RNG.select(null, rngChoicesThreeLetters, source))
		return rtn
	, ["0", "1", "2", "A", "2", "B", "2", "C", null])
	
	#10 Wide, 1 Deep
	simRNG(func(source):
		return [RNG.select(null, rngChoicesTenLetters, source)]
	, rngChoicesTenLetters + [null])
	
	#1 Wide, 10 Deep
	expectedOut = []
	for i in range(10):
		expectedOut.append(rngChoicesOneLetters[0])
	for i in range(10):
		expectedOut.append(null)
	simRNG(func(source):
		var rtn : Array = []
		for i in range(10):
			rtn.append(RNG.select(null, rngChoicesOneLetters, source))
		return rtn
	, expectedOut)
	
	#Rightmost Conditional 2-Wide, 3 Deep
	simRNG(func(source):
		var rtn : Array = []
		var out = RNG.select(null, rngChoicesTwoNumbers, source)
		rtn.append(out)
		if out == rngChoicesTwoNumbers[0]:
			out = RNG.select(null, rngChoicesTwoLetters, source)
			rtn.append(out)
			if out == rngChoicesTwoLetters[0]:
				rtn.append(RNG.select(null, rngChoicesTwoLetters2, source))
		return rtn
	, ["0", "A", "X", "0", "A", "Y", "0", "B", "1", null])
	
	#Rightmost Conditional 2-Wide, 3 Deep
	simRNG(func(source):
		var rtn : Array = []
		var out = RNG.select(null, rngChoicesTwoNumbers, source)
		rtn.append(out)
		if out == rngChoicesTwoNumbers[1]:
			out = RNG.select(null, rngChoicesTwoLetters, source)
			rtn.append(out)
			if out == rngChoicesTwoLetters[1]:
				rtn.append(RNG.select(null, rngChoicesTwoLetters2, source))
		return rtn
	, ["0", "1", "A", "1", "B", "X", "1", "B", "Y", null])
	
	
	if RNG.decisionIndices.size() != 0 or RNG.lastSource != null or RNG.finishedDeciding or RNG.isDeciding:
		print("EXIT TEST FAIL!")
		print(RNG.decisionIndices.size(), " != 0 or ", RNG.lastSource, " != null or ", RNG.finishedDeciding, " or ", RNG.isDeciding)
	else:
		print("EXIT TEST PASS!")
	
	RNG.start_rng_accumulator.disconnectSignal(onStartRNGAccumulator)
	RNG.end_rng_accumulator.disconnectSignal(onEndRNGAccumulator)

const RNG_DEPTH_MAX : int = 32
func simRNG(lambda : Callable, expectedOut : Array) -> void:
	var sourceKey : int = 0
	var rngOut : Array = []
	RNG.isDeciding = true
	while RNG.isDeciding:
		rngOut.append_array(lambda.call(sourceKey))
		sourceKey += 1
		if RNG.finishedDeciding:
			RNG.isDeciding = false
			RNG.finishedDeciding = false
		if sourceKey >= RNG_DEPTH_MAX:
			break
	print("##############\n", rngOut, " == \n", expectedOut)
	if rngOut == expectedOut:
		print("TEST PASSED")
	else:
		print("TEST FAILED")

func endRNGDecision() -> void:
	pass
