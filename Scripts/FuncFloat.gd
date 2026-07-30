extends RefCounted

class_name FuncFloat

var baseVal : float = 0.0
var muls : Dictionary = {}
var preAdds : Dictionary = {}
var postAdds : Dictionary = {}

var cacheValue : float = -1
var cacheValid : bool = false

signal changed()

func _init(newBaseVal : float = 0, newPasePreadd : float = 0.0, newBaseMul : float = 1.0, newBasePostadd : float = 0.0):
	self.baseVal = newBaseVal
	setPreadd("self", newPasePreadd)
	setMul("self", newBaseMul)
	setPostadd("self", newBasePostadd)

func setBaseVal(val):
	baseVal = val
	cacheValid = false
	changed.emit()

func setMul(key, val : float):
	muls[key] = val
	cacheValid = false
	changed.emit()

func setPreadd(key, val : float):
	preAdds[key] = val
	cacheValid = false
	changed.emit()

func setPostadd(key, val : float):
	postAdds[key] = val
	cacheValid = false
	changed.emit()

func eraseMul(key):
	muls.erase(key)
	cacheValid = false
	changed.emit()

func erasePostadd(key):
	postAdds.erase(key)
	cacheValid = false
	changed.emit()

func erasePreadd(key):
	preAdds.erase(key)
	cacheValid = false
	changed.emit()

func getVal() -> float:
	if cacheValid:
		return cacheValue
	
	var v = baseVal
	for a in preAdds.values():
		v += a
	for m in muls.values():
		v *= m
	for a in postAdds.values():
		v += a
	
	if not cacheValid:
		cacheValue = v
		cacheValid = true
	
	return v

func _to_string() -> String:
	var string = "(((" + str(baseVal)
	
	for v in preAdds.values():
		string += " + " + str(v)
	string += ") "
	
	for v in muls.values():
		string += " * " + str(v)
	string += ") "
	
	for v in postAdds.values():
		string += " + " + str(v)
	string += ") "
	
	string += "= " + str(getVal())
	
	return string
