extends Node

var _abilityDB : SubDB = SubDB.new()
var _sealDB : SubDB = SubDB.new()
var _ringDB : SubDB = SubDB.new()
var _demonDB : SubDB = SubDB.new()

var _abilityCoreDB : SubDB = SubDB.new()
var _abilityExteriorDB : SubDB = SubDB.new()

var _scriptToSubDB : Dictionary = {
	Ability : _abilityDB,
	SealModel : _sealDB,
	RingModel : _ringDB,
	DemonModel : _demonDB,
}

####################################################################################################

func _ready() -> void:
	addSeals()
	addAbilities()
	addRings()
	addDemons()

func addAbilities():
#	_abilityDB.add(AbilityWait)
	_abilityDB.add(AbilityStoppage)
	_abilityDB.add(AbilityClingToLife)
	_abilityDB.add(AbilityConsumption)
	_abilityDB.add(AbilityObliterate)
	_abilityDB.add(AbilityHesitance)
	_abilityDB.add(AbilityRipTide)
	_abilityDB.add(AbilityJoinMe)
	_abilityDB.add(AbilityConsumeTheStars)
	
	for abilityScript : Script in _abilityDB.getAllScripts():
		var abilityModel : Ability = _abilityDB.getModelByScriptSingleton(abilityScript)
		if abilityModel.coinPieceType == Entities.CoinPieceType.EXTERIOR:
			_abilityExteriorDB.add(abilityScript)
		elif abilityModel.coinPieceType == Entities.CoinPieceType.CORE:
			_abilityCoreDB.add(abilityScript)

func addSeals():
#	_sealDB.add(SealBlank)
	_sealDB.add(SealBlackSulfur)
	_sealDB.add(SealLead)
	_sealDB.add(SealQuicksilver)
	_sealDB.add(SealCleansing)
	_sealDB.add(SealCopper)
	_sealDB.add(SealCrystallization)
	_sealDB.add(SealAquaFortis)

func addRings():
#	_ringDB.add(RingVanityRing)
	_ringDB.add(RingTwinHeadedOuroboros)
	_ringDB.add(RingBowOfBellsEnd)
	_ringDB.add(RingBucketBrimCrustacean)
	_ringDB.add(RingCrownOfPrimaeNoctis)
	_ringDB.add(RingCircleOfLeeches)
	_ringDB.add(RingPreserverOfTheDrowned)
	_ringDB.add(RingDualTungstenSignate)
	_ringDB.add(RingAmazoniteClusterRing)
	_ringDB.add(RingBlankBand)

func addDemons():
#	_demonDB.add(DemonNameless)
	_demonDB.add(DemonEnvy)
	_demonDB.add(DemonGluttony)
	#_demonDB.add(DemonGreed)
	#_demonDB.add(DemonLust)
	#_demonDB.add(DemonPride)
	_demonDB.add(DemonSloth)
	#_demonDB.add(DemonWrath)

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

func getRing(ringScript : Script) -> RingModel:
	return _getFromSubByScript(_ringDB, ringScript)

func getRingSingleton(ringScript : Script) -> RingModel:
	return _getFromSubByScriptSingleton(_ringDB, ringScript)

func getDemon(demonScript : Script) -> DemonModel:
	return _getFromSubByScript(_demonDB, demonScript)

func getDemonSingleton(demonScript : Script) -> DemonModel:
	return _getFromSubByScriptSingleton(_demonDB, demonScript)

func getRandomAbilityScript() -> Script:
	return _abilityDB.getRandomScript()

func getRandomAbilityCoreScript() -> Script:
	return _abilityCoreDB.getRandomScript()

func getRandomAbilityExteriorScript() -> Script:
	return _abilityExteriorDB.getRandomScript()

func getRandomRingScript() -> Script:
	return _ringDB.getRandomScript()

func getRandomDemonScript() -> Script:
	return _demonDB.getRandomScript()

func getRandomDemonScriptsNoRepeat(num : int) -> Array[Script]:
	return _demonDB.getRandomScriptNoRepeat(num)
