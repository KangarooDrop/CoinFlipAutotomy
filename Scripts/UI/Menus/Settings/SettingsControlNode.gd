extends Control

class_name SettingsControlNode

const OFFSET_LABEL : float = 128.0
const OFFSET_BUTTON : float = 128.0
const OFFSET_TOTAL : float = OFFSET_LABEL + OFFSET_BUTTON*2

var actionName : String = ""

@onready var actionNameLabel : Label = get_node("%Label")
@onready var primaryButton : ButtonNine = get_node("%PrimaryButtonNine")
@onready var secondaryButton : ButtonNine = get_node("%SecondaryButtonNine")

signal request_control_primary(settingControlNode : SettingsControlNode)
signal request_control_secondary(settingControlNode : SettingsControlNode)
signal request_default_primary(settingControlNode : SettingsControlNode)
signal request_default_secondary(settingControlNode : SettingsControlNode)

####################################################################################################

func _onPrimaryButtonPressed() -> void:
	primaryButton.button.release_focus()
	request_control_primary.emit(self)

func _onPrimaryResetPressed() -> void:
	request_default_primary.emit(self)

func _onSecondaryButtonPressed() -> void:
	secondaryButton.button.release_focus()
	request_control_secondary.emit(self)

func _onSecondaryResetPressed() -> void:
	request_default_secondary.emit(self)

func _setButtonKeycode(button : ButtonNine, keycode : int) -> void:
	var keyString : String = " "
	if keycode != -1:
		keyString = OS.get_keycode_string(keycode)
	button.setText("[center]" + keyString + "[/center]")

####################################################################################################

func setActionName(newActionName : String) -> void:
	actionName = newActionName
	actionNameLabel.text = newActionName.capitalize()

func setPrimaryControl(keycode : int) -> void:
	_setButtonKeycode(primaryButton, keycode)

func setSecondaryControl(keycode : int) -> void:
	_setButtonKeycode(secondaryButton, keycode)
