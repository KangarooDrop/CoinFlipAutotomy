extends RefCounted
class_name CFSignal

var _callables : Array[Callable] = []

signal finished()

func connectSignal(callable : Callable) -> void:
	_callables.append(callable)

func disconnectSignal(callable : Callable) -> void:
	_callables.erase(callable)

func emitSignal(...argv : Array) -> void:
	for callable : Callable in _callables:
		await callable.callv(argv)
	finished.emit()
