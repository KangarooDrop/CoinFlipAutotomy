@tool
extends Node

@export_group("Globals")
@export_file_path("*.json") var engLocPath : String = ""
@export_file_path("*.gd") var modelDBScript : String = ""

@export_group("Rings")
@export_dir var ringScriptPath : String = ""
@export_file_path("*.gd") var ringScriptBase : String = ""
@export_dir var ringTexturePath : String = ""

@export_group("Ops")
@export_file_path("*.gd") var fileToRename : String = ""
@export var renamedPascaleCase : String = ""
@export var renameDisplayName : String = ""
@export_tool_button("Rename", "Callable") var renameButton = onRenamePressed

enum MODEL_TYPE {NONE, RING, COIN_PIECE, ABILITY}

const modelTypeToSignatureString : Dictionary = {
	MODEL_TYPE.COIN_PIECE : "CP",
	MODEL_TYPE.RING : "Ring",
	MODEL_TYPE.ABILITY : "Ability"
}

func validateOpsData() -> bool:
	if fileToRename.is_empty():
		print("ERROR: Ops path is empty.")
		return false
	elif not FileAccess.file_exists(fileToRename):
		print("ERROR: Ops file not found.")
		return false
	
	if renamedPascaleCase.is_empty():
		print("ERROR: Rename Pascal Case is empty.")
		return false
	
	if renameDisplayName.is_empty():
		print("ERROR: Rename Display Name is empty")
		return false
	
	return true

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

func validateSignature() -> bool:
	var renameFileName : String = fileToRename.get_file()
	for check : String in modelTypeToSignatureString.values():
		if renamedPascaleCase.left(check.length()) == check:
			if renameFileName.left(check.length()) != check:
				print("ERROR: Mismatched model signatures.")
				return false
			else:
				return true
	print("ERROR: Could not verify signature.")
	return false

static func getModelType(model : LocalizedModel) -> MODEL_TYPE:
	if model is RingModel:
		return MODEL_TYPE.RING
	elif model is CoinPieceModel:
		return MODEL_TYPE.COIN_PIECE
	elif model is Ability:
		return MODEL_TYPE.ABILITY
	else:
		return MODEL_TYPE.NONE

func getWithoutSignature(pacaleCaseString : String, modelType : MODEL_TYPE) -> String:
	var chars : String = modelTypeToSignatureString[modelType]
	return pacaleCaseString.right(pacaleCaseString.length() - chars.length())

func replaceDictRecursive(val : Dictionary, oldKey : String, newKey : String, newName : String) -> bool:
	if typeof(val) == TYPE_DICTIONARY:
		for k in val.keys():
			if k != oldKey:
				if typeof(val[k]) == TYPE_DICTIONARY:
					if replaceDictRecursive(val[k], oldKey, newKey, newName):
						return true
			else:
				var dictData : Dictionary = val[k]
				dictData["name"] = newName
				val.erase(k)
				val[newKey] = dictData
				return true
	return false

func onRenamePressed() -> void:
	if not validateOpsData():
		return
	if not validateSignature():
		return
	if not validateGlobals():
		return
	
	var model : LocalizedModel = load(fileToRename).new()
	var modelType : MODEL_TYPE = getModelType(model)
	var hasArt : bool = model.has_method("getTexturePath")
	
	if modelType == MODEL_TYPE.NONE:
		print("ERROR: Model type unknown.")
		return
	
	var modelScriptFile : FileAccess = FileAccess.open(fileToRename, FileAccess.READ)
	var oldModelScriptText : String = modelScriptFile.get_as_text()
	modelScriptFile.close()
	
	var oldPascaleCase : String = ""
	for line : String in oldModelScriptText.rsplit("\n"):
		if line.begins_with("class_name"):
			oldPascaleCase = line.right(line.length() - "class_name ".length())
	if oldPascaleCase.is_empty():
		print("ERROR: Could not find old ClassName.")
		return
	
	var renameNoSig : String = getWithoutSignature(renamedPascaleCase, modelType)
	var renameSnakeNoSign : String = renameNoSig.to_snake_case()
	var renameCapitalNoSign : String = renameSnakeNoSign.to_upper()
	
	var oldNoSig : String = getWithoutSignature(oldPascaleCase, modelType)
	var oldSnakeNoSign : String = oldNoSig.to_snake_case()
	var oldCapitalNoSign : String = oldSnakeNoSign.to_upper()
	
	################################################################################################
	
	var newModelScriptText : String = oldModelScriptText
	#Replaces class_name : RingVanityRing -> RingNewName
	if newModelScriptText.find(oldPascaleCase) == -1:
		print("ERROR: Could not find class_name match in model file.")
		return
	newModelScriptText = newModelScriptText.replace(oldPascaleCase, renamedPascaleCase)
	#Replaces getLocID : "VANITY_RING" -> "NEW_NAME"
	if newModelScriptText.find("\"" + oldCapitalNoSign + "\"") == -1:
		print("ERROR: Could not find loc id match in model file.")
		return
	newModelScriptText = newModelScriptText.replace("\"" + oldCapitalNoSign + "\"", "\"" + renameCapitalNoSign + "\"")
	#Replaces getTexturePath : "vanity_ring.png" -> "new_name.png"
	if hasArt:
		if newModelScriptText.find("\"" + oldSnakeNoSign + ".png\"") == -1:
			print("ERROR: Could not find art file match in model file.")
			return
		newModelScriptText = newModelScriptText.replace("\"" + oldSnakeNoSign + ".png\"", "\"" + renameSnakeNoSign + ".png\"")
	
	################################################################################################
	
	var localizationFile : FileAccess = FileAccess.open(engLocPath, FileAccess.READ)
	var localizationDict : Dictionary = JSON.parse_string(localizationFile.get_as_text())
	localizationFile.close()
	
	if not replaceDictRecursive(localizationDict, oldCapitalNoSign, renameCapitalNoSign, renameDisplayName):
		print("ERROR: Could not find localization key in eng.json.")
		return
	
	################################################################################################
	
	var dbFile : FileAccess = FileAccess.open(modelDBScript, FileAccess.READ)
	var oldDBScriptString : String = dbFile.get_as_text()
	dbFile.close()
	
	if oldDBScriptString.find("(" + oldPascaleCase + ")") == -1:
		print("WARNING: Could not find model in ModelDB script.")
	var newDBScriptString = oldDBScriptString.replace("(" + oldPascaleCase + ")", "(" + renamedPascaleCase + ")")
	
	################################################################################################
	"""
	TODO:
		save over model script file
		save over ModelDB
		save over localization file
		rename model script file
		rename art file
		change fileToRename to new file name
	"""
	
	modelScriptFile = FileAccess.open(fileToRename, FileAccess.WRITE)
	modelScriptFile.store_string(newModelScriptText)
	modelScriptFile.close()
	
	dbFile = FileAccess.open(modelDBScript, FileAccess.WRITE)
	dbFile.store_string(newDBScriptString)
	dbFile.close()
	
	localizationFile = FileAccess.open(engLocPath, FileAccess.WRITE)
	localizationFile.store_string(JSON.stringify(localizationDict, "\t"))
	localizationFile.close()
	
	var renameModelScriptPath : String = fileToRename.get_base_dir() + "/" + renamedPascaleCase + ".gd"
	DirAccess.rename_absolute(fileToRename, renameModelScriptPath)
	if hasArt:
		var oldArtPath : String = model.getTexturePath()
		var renameArtPath : String = oldArtPath.get_base_dir() + "/" + renameSnakeNoSign + ".png"
		DirAccess.rename_absolute(oldArtPath, renameArtPath)
	
	fileToRename = renameModelScriptPath
	
	################################################################################################
	
	print("Successfully renamed ", oldPascaleCase, " to ", renamedPascaleCase, ".")

#@export_dir coinPieceScriptPath : Strin
