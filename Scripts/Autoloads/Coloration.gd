extends Node

const colorGold0 : Color = Color("#f2e749")
const colorGold1 : Color = Color("#e5be22")
const colorGold2 : Color = Color("#d97e16")
const colorGold3 : Color = Color("#bf481d")
const colorGold4 : Color = Color("#992817")
const colorGold5 : Color = Color("#732017")
const colorGold6 : Color = Color("#4d130f")

const colorMixed0 : Color = Color("#b3caa4")
const colorMixed1 : Color = Color("#d4897e")
const colorMixed2 : Color = Color("#ae5242")
const colorMixed3 : Color = Color("#7e344c")
const colorMixed4 : Color = Color("#651e33")
const colorMixed5 : Color = Color("#451927")
const colorMixed6 : Color = Color("#290908")

const colorPurple0 : Color = Color("#74aeff")
const colorPurple1 : Color = Color("#c355da")
const colorPurple2 : Color = Color("#84266e")
const colorPurple3 : Color = Color("#3e207b")
const colorPurple4 : Color = Color("#31144f")
const colorPurple5 : Color = Color("#171237")
const colorPurple6 : Color = Color("#000000")

var colorsGold : Array[Color] = \
	[colorGold0, colorGold1, colorGold2, colorGold3, colorGold4, colorGold5, colorGold6]

var colorsMixed : Array[Color] = \
	[colorMixed0, colorMixed1, colorMixed2, colorMixed3, colorMixed4, colorMixed5, colorMixed6]

var colorsPurple : Array[Color] = \
	[colorPurple0, colorPurple1, colorPurple2, colorPurple3, colorPurple4, colorPurple5, colorPurple6]

var colorMat : Array = [colorsGold, colorsMixed, colorsPurple]

var printShaderVars : bool = false

func _ready() -> void:
	if printShaderVars:
		var strBase : String = "const vec4 color%s%d = vec4(%f, %f, %f, 1.0);"
		var colorNames : Array[String] = ["Gold", "Mixed", "Purple"]
		for i in range(colorNames.size()):
			var cName : String = colorNames[i]
			for j in range(7):
				print(strBase % [cName, j, colorMat[i][j].r, colorMat[i][j].g, colorMat[i][j].b])
