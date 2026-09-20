extends RefCounted

class_name StarterData

var sourceDemon = null
var startingAbilityTypes : Array[Script] = []
var startingRingTypes : Array[Script] = []

func _init(demon, abilityTypes : Array[Script], ringTypes : Array[Script]) -> void:
	sourceDemon = demon
	startingAbilityTypes = abilityTypes
	startingRingTypes = ringTypes

func createHandModel() -> HandModel:
	var handModel : HandModel = HandModel.new(sourceDemon)
	for ringType : Script in startingRingTypes:
		handModel.addRing(ModelDB.getRing(ringType))
	return handModel

func createCoinFaceModel() -> CoinFaceModel:
	var coinFaceModel : CoinFaceModel = CoinFaceModel.new()
	for abilityScript : Script in startingAbilityTypes:
		coinFaceModel.addCoinPieceToNextSocket(CoinPieceModel.new().setAbilityScript(abilityScript))
	return coinFaceModel

func createPlayerModel() -> PlayerModel:
	return PlayerModel.new(sourceDemon, createHandModel(), createCoinFaceModel())
