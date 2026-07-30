extends Node

const CoinPieceType = preload("res://Scripts/Entities/CoinPieceType.gd").CoinPieceType
const CoinPieceSocketScript : Script = preload("res://Scripts/Entities/CoinPieceSocketIndex.gd")
const CoinPieceSocketIndex = CoinPieceSocketScript.CoinPieceSocketIndex
const AbilityTargetType = preload("res://Scripts/Entities/AbilityTargetType.gd").AbilityTargetType
const SealBackgroundScript = preload("res://Scripts/Entities/SealBackgroundType.gd")
const SealBackgroundType = SealBackgroundScript.SealBackgroundType

func getAllNonNone(enumType : Dictionary) -> Array:
	if enumType.has("NONE"):
		return getAllExceptVals(enumType, [enumType["NONE"]])
	else:
		return enumType.values()

func getAllExceptVals(enumType : Dictionary, exceptions : Array) -> Array:
	var allExcept : Array = enumType.values()
	for val in exceptions:
		allExcept.erase(val)
	return allExcept
