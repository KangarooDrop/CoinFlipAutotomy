extends RefCounted
class_name CFSignal

const WAIT_TYPE_NONE : int = 0
const WAIT_TYPE_SERIES : int = 1
const WAIT_TYPE_PARALLEL : int = 2

var _waitType : int = WAIT_TYPE_SERIES
var _callables : Array[Callable] = []

signal finished()

func _init(newWaitType : int = WAIT_TYPE_SERIES) -> void:
	self._waitType = newWaitType

func connectSignal(callable : Callable) -> void:
	_callables.append(callable)

func disconnectSignal(callable : Callable) -> void:
	_callables.erase(callable)

func emitSignal(...argv : Array) -> void:
	if _waitType == WAIT_TYPE_NONE:
		_emitNoWait(argv)
	if _waitType == WAIT_TYPE_SERIES:
		await _emitInSeries(argv)
	elif _waitType == WAIT_TYPE_PARALLEL:
		await _emitInParallel(argv)

func _emitNoWait(argv : Array) -> void:
	for callable : Callable in _callables:
		callable.callv(argv)
	finished.emit()

func _emitInSeries(argv : Array) -> void:
	for callable : Callable in _callables:
		await callable.callv(argv)
	finished.emit()

func _emitInParallel(argv : Array) -> void:
	var parallelizer : _Parallelizer = _Parallelizer.new()
	parallelizer.emitSignal(_callables, argv)
	if not parallelizer.finished:
		await parallelizer.all_emitted
		
class _Parallelizer:
	signal all_emitted
	var finished : bool = false
	var waitCounter : int = 0
	
	func _parallelWaitComplete() -> void:
		all_emitted.emit()
		finished = true
	
	func _emitParallel(callable : Callable, argv) -> void:
		await callable.callv(argv)
		waitCounter -= 1
		if waitCounter == 0:
			_parallelWaitComplete()
	
	func emitSignal(callables : Array[Callable], argv : Array) -> void:
		waitCounter = callables.size()
		for callable : Callable in callables:
			_emitParallel(callable, argv)
		if waitCounter == 0:
			_parallelWaitComplete()
		
		
