extends RichTextLabel

class_name ButtonNine

@onready var button : Button = get_node("%ButtonNode")

signal pressed()
signal button_down()
signal button_up()

func setText(newText : String) -> void:
	self.text = newText
	self.size = Vector2.ZERO

func onPressed() -> void:
	pressed.emit()
func onButtonDown() -> void:
	button_down.emit()
func onButtonUp() -> void:
	button_up.emit()
