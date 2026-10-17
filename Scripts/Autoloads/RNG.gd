extends Node

func getRandi() -> int:
	return randi()

func getRandf() -> float:
	return randf()

"""
var isDeciding : bool = false
var currentSource : Variant = null
var decisionIndices : Array[int] = []
var decisionSizes : Array[int] = []
var currentIndex : int = 0
var setNextToCurrent : bool = false

const outputVerbose : bool = true
"""

signal start_rng_accumulator()
signal end_rng_accumulator()


var isDeciding : bool = false
var finishedDeciding : bool = false
var lastSource : Variant = null
var decisionIndices : Array[int] = []
var decisionSizes : Array[int] = []
var currentIndex : int = 0

func select(from : Array, source : Variant) -> Variant:
	if not isDeciding:
		return from[randi() % from.size()]
	else:
		if finishedDeciding:
			return null
		if lastSource == null:
			start_rng_accumulator.emit()
		if source != lastSource:
			lastSource = source
			currentIndex = 0
		if currentIndex >= decisionIndices.size():
			if currentIndex != 0:
				decisionIndices[currentIndex-1] -= 1
			decisionIndices.append(0)
			decisionSizes.append(from.size())
		while decisionIndices.size()>0 and decisionIndices[decisionIndices.size()-1] >= decisionSizes[decisionIndices.size()-1]:
			var endIndex : int = decisionIndices.size()-1
			if endIndex != 0:
				decisionIndices[endIndex-1] += 1
			decisionIndices.remove_at(endIndex)
			decisionSizes.remove_at(endIndex)
		
		var rtn = null
		var ended = currentIndex >= decisionIndices.size()
		if not ended:
			rtn = from[decisionIndices[currentIndex]]
			if currentIndex == decisionIndices.size()-1:
				decisionIndices[currentIndex] += 1
			currentIndex += 1
		
		"""
		print("source=", source)
		print(decisionIndices)
		print(decisionSizes)
		print("index=", currentIndex)
		print("rtn=", rtn)
		print()
		"""
		
		if ended:
			lastSource = null
			finishedDeciding = true
			end_rng_accumulator.emit()
		
		return rtn

"""

func select(from : Array, source : Variant) -> Variant:
	if not isDeciding:
		return from[randi() % from.size()]
	else:
		if currentSource == null:
			currentSource = source
			currentIndex = 0
			decisionIndices = [0]
			decisionSizes = [from.size()]
		else:
			if currentSource == source:
				if currentIndex != 0:
					decisionIndices[currentIndex-1] -= 1
				decisionIndices.append(0)
				decisionSizes.append(from.size())
			else:
				if currentIndex == decisionIndices.size() and decisionIndices[currentIndex-1] >= decisionSizes[currentIndex-1]:
					thinTree()
				if currentIndex >= decisionIndices.size():
					currentIndex = currentIndex % decisionIndices.size()
			if setNextToCurrent and currentIndex == decisionIndices.size()-1:
				currentSource = source
				setNextToCurrent = false
		
		var rtn = null
		if decisionIndices.size() == 1 and decisionIndices[currentIndex] == decisionSizes[currentIndex]:
			push_warning("WARNING: RNG Tree is indeterminate. Please Fix for the sake of the robots.\nSimple Fix: RNG.select([A, B]) dependent on B as an output -> RNG.select([B, A])")
		else:
			rtn = from[decisionIndices[currentIndex]]
		
		if currentIndex == decisionIndices.size()-1:
			decisionIndices[currentIndex] += 1
		currentIndex += 1
		
		if outputVerbose:
			printVerbose(source, rtn)
	
		
		return rtn

func thinTree() -> void:
	for j in range(currentIndex-1, -1, -1):
		if j != 0:
			if decisionIndices[j] >= decisionSizes[j]:
				decisionIndices[j-1] += 1
				decisionIndices.remove_at(j)
				decisionSizes.remove_at(j)
				currentIndex -= 1
				setNextToCurrent = true
		else:
			if decisionIndices[j] >= decisionSizes[j]:
				decisionIndices.remove_at(j)
				decisionSizes.remove_at(j)
				currentIndex -= 1
				currentSource = null
				isDeciding = false
				setNextToCurrent = false

func printVerbose(source, rtn) -> void:
	print("source=", source)
	print(decisionIndices)
	print(decisionSizes)
	print("index=", currentIndex)
	print("rtn=", rtn)
	print()

"""
