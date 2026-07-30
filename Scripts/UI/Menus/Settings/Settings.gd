extends CanvasLayer

const INDEX_GAMEPLAY : int = 0
const INDEX_VOLUME : int = 1
const INDEX_CONTROLS : int = 2

var currentTab : ButtonNine = null
var currentPage : Control = null
var settingsData : Dictionary = {}

@onready var listenerWindow : Control = get_node("%ListenerWindow")
@onready var inputBlocker : Control = get_node("%ListenerInputBlocker")
@onready var scrollContainer : ScrollContainer = get_node("%ScrollContainer")

@onready var gameplayTab : ButtonNine = get_node("%GameplayTab")
@onready var volumeTab : ButtonNine = get_node("%VolumeTab")
@onready var controlsTab : ButtonNine = get_node("%ControlsTab")
@onready var tabs : Array = [gameplayTab, volumeTab, controlsTab]

@onready var gameplayPage : Control = get_node("%GameplayPage")
@onready var volumePage : Control = get_node("%VolumePage")
@onready var controlsPage : Control = get_node("%ControlsPage")
@onready var pages : Array = [gameplayPage, volumePage, controlsPage]

const SETTINGS_FILE_PATH : String = "user://settings.json"

signal keycode_received(keycode : Key)

var DEFAULT_SETTINGS_DATA : Dictionary = \
{
	"gameplay": [
		["dummy", 0],
	],
	"volume": [
		["master", 0.5],
	],
	"controls":[
		["escape", 			[KEY_ESCAPE, 	-1]],
		["skip", 			[KEY_SPACE, 	-1]],
		["action_1", 		[KEY_1, 		-1]],
		["action_2", 		[KEY_2, 		-1]],
		["action_3", 		[KEY_3, 		-1]],
		["action_4", 		[KEY_4, 		-1]],
		["action_5", 		[KEY_5, 		-1]],
		["action_6", 		[KEY_6, 		-1]],
		["action_7", 		[KEY_7, 		-1]],
		["action_8", 		[KEY_8, 		-1]],
		["action_9", 		[KEY_9, 		-1]],
	]
}

static func _getControlsKeycodes(settingsDataStatic : Dictionary, actionName : String) -> Array:
	for controlsData : Array in settingsDataStatic["controls"]:
		if controlsData[0] == actionName:
			return controlsData[1]
	return []

static func _replaceControlsKeycode(settingsDataStatic : Dictionary, actionName : String, isPrimary : bool, keycode : Key) -> void:
	for controlsData : Array in settingsDataStatic["controls"]:
		if controlsData[0] == actionName:
			controlsData[1][0 if isPrimary else 1] = keycode

func _verifySettingsData() -> void:
	var verifiedSettings : Dictionary = {}
	for k in DEFAULT_SETTINGS_DATA.keys():
		verifiedSettings[k] = []
	var resaveSettings : bool = false
	
	#Verifying gameplay settings
	verifiedSettings["gameplay"] = settingsData["gameplay"].duplicate()
	
	#Verifying volume settings
	verifiedSettings["volume"] = settingsData["volume"].duplicate()
	
	#Verifying controls settings
	for i in range(DEFAULT_SETTINGS_DATA["controls"].size()):
		var actionName : String = DEFAULT_SETTINGS_DATA["controls"][i][0]
		if not InputMap.has_action(actionName):
			InputMap.add_action(actionName)
			push_error("ERROR: Unknown default action name found: ", actionName, ". Please fix.")
		var fileControls : Array = _getControlsKeycodes(settingsData, actionName)
		if fileControls.is_empty():
			verifiedSettings["controls"].append([actionName, DEFAULT_SETTINGS_DATA["controls"][i][1]])
			resaveSettings = true
		else:
			verifiedSettings["controls"].append([actionName, fileControls])
	for i in range(settingsData["controls"].size()):
		var actionName : String = settingsData["controls"][i][0]
		if _getControlsKeycodes(DEFAULT_SETTINGS_DATA, actionName).is_empty():
			resaveSettings = true
			break
	
	settingsData = verifiedSettings
	if resaveSettings:
		push_warning("WARNING: Detected discrepency while verifying settings file. Resaving.")
		_saveSettingsFile()

func _readSettingsFile() -> void:
	print("Fetching settings file.")
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		push_warning("WARNING: Could not find settings file.")
		settingsData = DEFAULT_SETTINGS_DATA.duplicate()
		_saveSettingsFile()
	var text : String = FileAccess.get_file_as_string(SETTINGS_FILE_PATH)
	var json = JSON.parse_string(text)
	if json == null:
		push_warning("WARNING: Could not parse settings file.")
		settingsData = DEFAULT_SETTINGS_DATA.duplicate()
		_saveSettingsFile()
	print("Succefully parsed settings file.")
	settingsData = json

func _saveSettingsFile() -> Error:
	var fileAccess : FileAccess = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	var error : Error = Error.OK
	if fileAccess == null:
		error = FileAccess.get_open_error()
	else:
		fileAccess.store_string(JSON.stringify(settingsData, "    "))
		error = fileAccess.get_error()
	if error != OK:
		push_warning("WARNING : Could not save settings file: op-code=", error, ".")
	return error

func _addActionsToMap() -> void:
	for i in range(DEFAULT_SETTINGS_DATA["controls"].size()):
		var actionName : String = settingsData["controls"][i][0]
		var keycodePrimary : Key = settingsData["controls"][i][1][0]
		var keycodeSecondary : Key = settingsData["controls"][i][1][1]
		if keycodePrimary != -1:
			var eventPrimary : InputEventKey = InputEventKey.new()
			eventPrimary.keycode = keycodePrimary
			InputMap.action_add_event(actionName, eventPrimary)
		if not InputMap.has_action(actionName):
			var eventSecondary : InputEventKey = InputEventKey.new()
			eventSecondary.keycode = keycodeSecondary
			InputMap.action_add_event(actionName, eventSecondary)

func _ready() -> void:
	_readSettingsFile()
	_verifySettingsData()
	_addActionsToMap()
	_initControlsPage()
	hideSettings()

####################################################################################################

func _setIndex(index : int) -> void:
	self.currentTab = tabs[index]
	self.currentPage = pages[index]
	for i in range(tabs.size()):
		if i != index:
			tabs[i].button.disabled = false
			pages[i].hide()
	tabs[index].button.disabled = true
	pages[index].show()
	scrollContainer.get_v_scroll_bar().value = 0.0

func _initControlsPage() -> void:
	for controlsData : Array in settingsData["controls"]:
		var settingsControlNode : SettingsControlNode = Preloader.create(Preloader.settingsControlPacked)
		controlsPage.add_child(settingsControlNode)
		var actionName : String = controlsData[0]
		var actionKeys : Array = controlsData[1]
		settingsControlNode.setActionName(actionName)
		settingsControlNode.setPrimaryControl(actionKeys[0])
		settingsControlNode.setSecondaryControl(actionKeys[1])
		settingsControlNode.request_control_primary.connect(_onRequestedControlsPrimary)
		settingsControlNode.request_default_primary.connect(_onRequestedDefaultPrimary)
		settingsControlNode.request_control_secondary.connect(_onRequestedControlsSecondary)
		settingsControlNode.request_default_secondary.connect(_onRequestedDefaultSecondary)

func _getKeycode() -> Signal:
	listenerWindow.show()
	inputBlocker.show()
	return keycode_received

func _onRequestedControlsPrimary(settingsControlNode : SettingsControlNode) -> void:
	var keycode : Key = await self._getKeycode()
	settingsControlNode.setPrimaryControl(keycode)
	_replaceControlsKeycode(settingsData, settingsControlNode.actionName, true, keycode)
	_saveSettingsFile()

func _onRequestedDefaultPrimary(settingsControlNode : SettingsControlNode) -> void:
	var keycode : Key = _getControlsKeycodes(DEFAULT_SETTINGS_DATA, settingsControlNode.actionName)[0]
	settingsControlNode.setPrimaryControl(keycode)
	_replaceControlsKeycode(settingsData, settingsControlNode.actionName, true, keycode)
	_saveSettingsFile()

func _onRequestedControlsSecondary(settingsControlNode : SettingsControlNode) -> void:
	var keycode : Key = await self._getKeycode()
	settingsControlNode.setSecondaryControl(keycode)
	_replaceControlsKeycode(settingsData, settingsControlNode.actionName, false, keycode)
	_saveSettingsFile()

func _onRequestedDefaultSecondary(settingsControlNode : SettingsControlNode) -> void:
	var keycode : Key = _getControlsKeycodes(DEFAULT_SETTINGS_DATA, settingsControlNode.actionName)[1]
	settingsControlNode.setSecondaryControl(keycode)
	_replaceControlsKeycode(settingsData, settingsControlNode.actionName, false, keycode)
	_saveSettingsFile()

func _input(event: InputEvent) -> void:
	if inputBlocker.visible and event is InputEventKey and event.is_pressed() and not event.is_echo():
		keycode_received.emit(event.keycode)
		listenerWindow.hide()
		inputBlocker.hide()

####################################################################################################

func showSettings() -> void:
	_setIndex(INDEX_GAMEPLAY)
	show()

func hideSettings() -> void:
	hide()

func onGameplayTabPressed() -> void:
	_setIndex(INDEX_GAMEPLAY)

func onVolumeTabPressed() -> void:
	_setIndex(INDEX_VOLUME)

func onControlsTabPressed() -> void:
	_setIndex(INDEX_CONTROLS)

func onBackPressed() -> void:
	hideSettings()
