extends Node

var _abilityDB : SubDB = SubDB.new()
var _sealDB : SubDB = SubDB.new()
var _coinPieceDB : SubDB = SubDB.new()
var _coinPieceExteriorDB : SubDB = SubDB.new()
var _coinPieceCoreDB : SubDB = SubDB.new()
var _ringDB : SubDB = SubDB.new()
var _demonDB : SubDB = SubDB.new()

var _scriptToSubDB : Dictionary = {
	Ability : _abilityDB,
	SealModel : _sealDB,
	CoinPieceModel : _coinPieceDB,
	RingModel : _ringDB,
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
	
	_ringDB.add(RingVanityRing)
	_ringDB.add(RingTwinHeadedOuroboros)
	_ringDB.add(RingBowOfBellsEnd)
	_ringDB.add(RingBucketBrimCrustacean)
	_ringDB.add(RingCrownOfPrimaeNoctis)
	_ringDB.add(RingCircleOfLeeches)
	_ringDB.add(RingPreserverOfTheDrowned)
	
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

func getRing(ringScript : Script) -> RingModel:
	return _getFromSubByScript(_ringDB, ringScript)

func getRingSingleton(ringScript : Script) -> RingModel:
	return _getFromSubByScriptSingleton(_ringDB, ringScript)

func getDemon(demonScript : Script) -> DemonModel:
	return _getFromSubByScript(_demonDB, demonScript)

func getDemonSingleton(demonScript : Script) -> DemonModel:
	return _getFromSubByScriptSingleton(_demonDB, demonScript)

func getRandomCoinPieceCoreScript() -> Script:
	return _coinPieceCoreDB.getRandomScript()

func getRandomCoinPieceExteriorScript() -> Script:
	return _coinPieceExteriorDB.getRandomScript()

func getRandomRingScript() -> Script:
	return _ringDB.getRandomScript()

func getRandomDemonScript() -> Script:
	return _demonDB.getRandomScript()

func getRandomDemonScriptsNoRepeat(num : int) -> Array[Script]:
	return _demonDB.getRandomScriptNoRepeat(num)
