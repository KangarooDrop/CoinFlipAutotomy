@tool
extends Node

@export_group("Globals")
@export_file_path("*.json") var engLocPath : String = "res://Localization/eng.json"
@export_file_path("*.gd") var modelDBScript : String = "res://Scripts/Models/ModelDB.gd"

@export_group("Basic Models")
@export_file_path("*.gd") var basicPathCoinPieceExterior : String = "res://Scripts/Models/CoinPieces/CPCounterweightExterior.gd"
@export_file_path("*.gd") var basicPathCoinPieceCore : String = "res://Scripts/Models/CoinPieces/CPCounterweightCore.gd"
@export_file_path("*.gd") var basicPathRing : String = "res://Scripts/Models/Rings/RingVanityRing.gd"
@export_file_path("*.gd") var basicPathAbility : String = "res://Scripts/Models/Abilities/AbilityMock.gd"
@export_file_path("*.gd") var basicPathSeal : String = "res://Scripts/Models/SealModels/SealEmpty.gd"
@export_file_path("*.gd") var basicPathDemon : String = "res://Scripts/Models/Demons/DemonGluttony.gd"

func getModelTypeToBasicPath(modelType : MODEL_TYPE, isCoinPieceCore : bool) -> String:
	if modelType == MODEL_TYPE.COIN_PIECE:
		if isCoinPieceCore:
			return basicPathCoinPieceExterior
		else:
			return basicPathCoinPieceCore
	elif modelType == MODEL_TYPE.RING:
		return basicPathRing
	elif modelType == MODEL_TYPE.ABILITY:
		return basicPathAbility
	elif modelType == MODEL_TYPE.SEAL:
		return basicPathSeal
	elif modelType == MODEL_TYPE.DEMON:
		return basicPathDemon
	else:
		return ""
func getModelTypeToFolderPath(modelType : MODEL_TYPE) -> String:
	return getModelTypeToBasicPath(modelType, false).get_base_dir() + "/"
func getAllFolderPaths() -> Array[String]:
	var rtn : Array[String] = []
	for modelType : MODEL_TYPE in MODEL_TYPE.keys():
		if modelType == MODEL_TYPE.NONE:
			continue
		rtn.append(getModelTypeToFolderPath(modelType))
	return rtn

enum MODEL_TYPE {NONE, RING, COIN_PIECE, ABILITY, SEAL, DEMON}

const modelTypeToSignatureString : Dictionary = {
	MODEL_TYPE.COIN_PIECE : "CP",
	MODEL_TYPE.RING : "Ring",
	MODEL_TYPE.ABILITY : "Ability",
	MODEL_TYPE.SEAL : "Seal",
	MODEL_TYPE.DEMON : "Demon",
}

static func getModelTypeFromModel(model : LocalizedModel) -> MODEL_TYPE:
	if model is RingModel:
		return MODEL_TYPE.RING
	elif model is CoinPieceModel:
		return MODEL_TYPE.COIN_PIECE
	elif model is Ability:
		return MODEL_TYPE.ABILITY
	elif model is SealModel:
		return MODEL_TYPE.SEAL
	else:
		return MODEL_TYPE.NONE

static func getModelTypeFromString(className : String) -> MODEL_TYPE:
	for modelType : MODEL_TYPE in modelTypeToSignatureString.keys():
		var check : String = modelTypeToSignatureString[modelType]
		if className.left(check.length()) == check:
			return modelType
	return MODEL_TYPE.NONE

func getWithoutSignature(pacaleCaseString : String) -> String:
	var modelType : MODEL_TYPE = getModelTypeFromString(pacaleCaseString)
	if modelType == MODEL_TYPE.NONE:
		return ""
	var chars : String = modelTypeToSignatureString[modelType]
	return pacaleCaseString.right(pacaleCaseString.length() - chars.length())

func validateGlobals() -> bool:
	if engLocPath.is_empty():
		print("ERROR: Localization path is empty.")
		return false
	elif not FileAccess.file_exists(engLocPath):
		print("ERROR: Localization file not found.")
		return false
	
	if modelDBScript.is_empty():
		print("ERROR: ModelDB path is empty")
		return false
	elif not FileAccess.file_exists(modelDBScript):
		print("ERROR: ModelDB file not found.")
		return false
	return true

#TODO: Add to new BuilderBase script

####################################################################################################

@export_group("Ops")
@export var newPascaleCase : String = ""
@export var newDisplayName : String = ""
@export var isCore : bool = false
@export_tool_button("Create", "Callable") var createButton = onCreatePressed

func getNewFilePath() -> String:
	var modelType : MODEL_TYPE = getModelTypeFromString(newPascaleCase)
	var folderPath : String = getModelTypeToFolderPath(modelType)
	return folderPath + newPascaleCase + ".gd"

func validateOpsData() -> bool:
	if getModelTypeFromString(newPascaleCase) == MODEL_TYPE.NONE:
		print("ERROR: Model Type could not be parsed.")
		return false
	
	var newFilePath : String = getNewFilePath()
	if FileAccess.file_exists(newFilePath):
		print("ERROR: File at ", newFilePath, " already exists.")
		return false
	
	return true

static func copyInDictionary(dict : Dictionary, fromKey, toKey, changes : Dictionary = {}) -> void:
	for k in dict.keys():
		if k == fromKey:
			var oldData = dict[k]
			if typeof(oldData) == TYPE_DICTIONARY:
				oldData = oldData.duplicate()
				for c in changes.keys():
					if not oldData.has(c):
						continue
					oldData[c] = changes[c]
			dict[toKey] = oldData
			return
		elif typeof(dict[k]) == TYPE_DICTIONARY:
			copyInDictionary(dict[k], fromKey, toKey, changes)

func onCreatePressed() -> void:
	if not validateOpsData():
		return
	if not validateGlobals():
		return
	
	var modelType : MODEL_TYPE = getModelTypeFromString(newPascaleCase)
	var folderPath : String = getModelTypeToFolderPath(modelType)
	var baseFilePath : String = getModelTypeToBasicPath(modelType, isCore)
	var model : LocalizedModel = load(baseFilePath).new()
	var baseArtPath : String = ""
	var baseArtFileName : String = ""
	if model.has_method("getTexturePath"):
		baseArtPath = model.getTexturePath()
		baseArtFileName = baseArtPath.get_file()
	model = null
	
	var baseFile : FileAccess = FileAccess.open(baseFilePath, FileAccess.READ)
	var baseScriptText : String = baseFile.get_as_text()
	baseFile.close()
	
	var baseClassName : String = baseFilePath.get_file().get_basename()
	var baseLocID : String = getWithoutSignature(baseClassName).to_snake_case().to_upper()
	var newLocID : String = getWithoutSignature(newPascaleCase).to_snake_case().to_upper()
	var newArtPath : String = ""
	var newArtFileName : String = ""
	#Getting art file path for new model
	if not baseArtPath.is_empty():
		newArtPath = baseArtPath.get_base_dir() + "/" + getWithoutSignature(newPascaleCase).to_snake_case() + ".png"
		newArtFileName = newArtPath.get_file()
	
	#Getting script text for new model
	var newScriptText : String = baseScriptText
	newScriptText = newScriptText.replace(baseClassName, newPascaleCase)
	newScriptText = newScriptText.replace("\"" + baseLocID + "\"", "\"" + newLocID + "\"")
	if not baseArtPath.is_empty():
		newScriptText = newScriptText.replace("\"" + baseArtFileName + "\"", "\"" + newArtFileName + "\"")
	
	#Copying new locID into localization dictionary
	var localizationFile : FileAccess = FileAccess.open(engLocPath, FileAccess.READ)
	var localizationDict : Dictionary = JSON.parse_string(localizationFile.get_as_text())
	localizationFile.close()
	copyInDictionary(localizationDict, baseLocID, newLocID, {"name":newDisplayName})
	
	#Adding new model to ModelDB
	var dbFile : FileAccess = FileAccess.open(modelDBScript, FileAccess.READ)
	var oldDBScriptString : String = dbFile.get_as_text()
	dbFile.close()
	var oldDBLines : PackedStringArray = oldDBScriptString.rsplit("\n")
	var lastDBIndex : int = -1
	var dbCheck : String = ""
	var baseModelDBAddLine : String = ""
	for i in range(oldDBLines.size()):
		var line : String = oldDBLines[i]
		if line.contains("(" + baseClassName + ")"):
			dbCheck = line.left(line.find("(" + baseClassName + ")"))
			baseModelDBAddLine = line
		if not dbCheck.is_empty() and line.contains(dbCheck):
			lastDBIndex = i
	if lastDBIndex == -1:
		print("WARNING: Could not find base model in ModelDB Script. Must be added manually.")
	else:
		oldDBLines.insert(lastDBIndex+1, baseModelDBAddLine.replace(baseClassName, newPascaleCase))
		#print("\n".join(oldDBLines))
	
	#Save file w/ newScriptText at getNewFilePath()
	var newFilePath : String = getNewFilePath()
	var newModelScriptFile : FileAccess = FileAccess.open(newFilePath, FileAccess.WRITE)
	newModelScriptFile.store_string(newScriptText)
	newModelScriptFile.close()
	
	#Copy baseArtPath to newArtPath
	DirAccess.copy_absolute(baseArtPath, newArtPath)
	
	#Save new localization text to eng.json
	localizationFile = FileAccess.open(engLocPath, FileAccess.WRITE)
	localizationFile.store_string(JSON.stringify(localizationDict, "\t"))
	localizationFile.close()
	
	#Resave ModelDB text
	dbFile = FileAccess.open(modelDBScript, FileAccess.WRITE)
	dbFile.store_string("\n".join(oldDBLines))
	dbFile.close()
	
	print("Successfully created model ", newPascaleCase, " at ", newFilePath)
