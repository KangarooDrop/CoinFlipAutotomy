extends Node

var _abilityDB : SubDB = SubDB.new()
var _sealDB : SubDB = SubDB.new()
var _coinPieceDB : SubDB = SubDB.new()
var _coinPieceExteriorDB : SubDB = SubDB.new()
var _coinPieceCoreDB : SubDB = SubDB.new()
var _fingerRingDB : SubDB = SubDB.new()
var _demonDB : SubDB = SubDB.new()

var _scriptToSubDB : Dictionary = {
	Ability : _abilityDB,
	SealModel : _sealDB,
	CoinPieceModel : _coinPieceDB,
	FingerRingModel : _fingerRingDB,
	DemonModel : _demonDB,
}

####################################################################################################

func _ready() -> void:
	_abilityDB.add(AbilityMock)
	_abilityDB.add(AbilityMockSeal)
	_abilityDB.add(AbilityStoppage)
	_abilityDB.add(AbilityDragUnder)
	_abilityDB.add(AbilityConsumption)
	_abilityDB.add(AbilityObliterate)
	_abilityDB.add(AbilityHesitance)
	_abilityDB.add(AbilityRipTide)
	_abilityDB.add(AbilityUntouchableHeat)
	
	_sealDB.add(SealAquaFortis)
	_sealDB.add(SealLead)
	_sealDB.add(SealQuicksliver)
	_sealDB.add(SealCleansing)
	_sealDB.add(SealCopper)
	
	_coinPieceCoreDB.add(CPCounterweightCore)
	_coinPieceCoreDB.add(CPAbyssalMaw)
	_coinPieceCoreDB.add(CPDrownardsVictim)
	
	_coinPieceExteriorDB.add(CPCounterweightExterior)
	_coinPieceExteriorDB.add(CPAtrophy)
	_coinPieceExteriorDB.add(CPOceansDescent)
	_coinPieceExteriorDB.add(CPDevouringSickness)
	_coinPieceExteriorDB.add(CPDismay)
	_coinPieceExteriorDB.add(CPAllureOfFlame)
	
	_fingerRingDB.add(RingVanityRing)
	_fingerRingDB.add(RingTwinHeadedOuroboros)
	_fingerRingDB.add(RingBowOfBellsEnd)
	_fingerRingDB.add(RingBucketBrimCrustacean)
	_fingerRingDB.add(RingCrownOfPrimaeNoctis)
	_fingerRingDB.add(RingCircleOfLeeches)
	_fingerRingDB.add(RingPreserverOfTheDrowned)
	
	_demonDB.add(DemonEnvy)
	_demonDB.add(DemonGluttony)
	#_demonDB.add(DemonGreed)
	#_addDemon(DemonLust)
	#_addDemon(DemonPride)
	_demonDB.add(DemonSloth)
	#_addDemon(DemonWrath)
	
	_coinPieceDB.merge(_coinPieceCoreDB)
	_coinPieceDB.merge(_coinPieceExteriorDB)

func _getFromSubByScript(subDB : SubDB, scr : Script) -> LocalizedModel:
	return subDB.getModelByScript(scr)

func _getFromSubByScriptSingleton(subDB : SubDB, scr : Script) -> LocalizedModel:
	return subDB.getModelByScriptSingleton(scr)

####################################################################################################

func getModel(modelScript : Script) -> LocalizedModel:
	var inheretedScript = modelScript.get_base_script()
	while inheretedScript != null:
		if _scriptToSubDB.has(inheretedScript):
			return _getFromSubByScript(_scriptToSubDB[inheretedScript], modelScript)
		inheretedScript = inheretedScript.get_base_script()
	return null

func getAbility(abilityScript : Script) -> Ability:
	return _getFromSubByScript(_abilityDB, abilityScript)

func getAbilitySingleton(abilityScript : Script) -> Ability:
	return _getFromSubByScriptSingleton(_abilityDB, abilityScript)

func getSeal(sealScript : Script) -> SealModel:
	return _getFromSubByScript(_sealDB, sealScript)

func getSealSingleton(sealScript : Script) -> SealModel:
	return _getFromSubByScriptSingleton(_sealDB, sealScript)

func getCoinPiece(coinPieceScript : Script) -> CoinPieceModel:
	return _getFromSubByScript(_coinPieceDB, coinPieceScript)

func getCoinPieceSingleton(coinPieceScript : Script) -> CoinPieceModel:
	return _getFromSubByScriptSingleton(_coinPieceDB, coinPieceScript)

func getFingerRing(fingerRingScript : Script) -> FingerRingModel:
	return _getFromSubByScript(_fingerRingDB, fingerRingScript)

func getFingerRingSingleton(fingerRingScript : Script) -> FingerRingModel:
	return _getFromSubByScriptSingleton(_fingerRingDB, fingerRingScript)

func getDemon(demonScript : Script) -> DemonModel:
	return _getFromSubByScript(_demonDB, demonScript)

func getDemonSingleton(demonScript : Script) -> DemonModel:
	return _getFromSubByScriptSingleton(_demonDB, demonScript)

func getRandomCoinPieceCoreScript() -> Script:
	return _coinPieceCoreDB.getRandomScript()

func getRandomCoinPieceExteriorScript() -> Script:
	return _coinPieceExteriorDB.getRandomScript()

func getRandomFingerRingScript() -> Script:
	return _fingerRingDB.getRandomScript()

func getRandomDemonScript() -> Script:
	return _demonDB.getRandomScript()

func getRandomDemonScriptsNoRepeat(num : int) -> Array[Script]:
	return _demonDB.getRandomScriptNoRepeat(num)
