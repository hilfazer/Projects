tool
extends "./TimeMeasureScene.gd"



func _ready():
	addMeasure(ArrayHack.new(), "ArrayHack")
	addMeasure(IfElseTernary.new(),   "IfElseTernary")


class ArrayHack extends MeasureBase:
	var booleans : Array
	func setup():
		booleans.resize(loopCount)
		for i in loopCount:
			booleans[i] = bool(randi() % 2)


	func _execute():
		for b in booleans:
# warning-ignore:unused_variable
			var x = ["true", "false"][int(b)]


	func teardown():
		booleans.clear()


class IfElseTernary extends MeasureBase:
	var booleans : Array
	func setup():
		booleans.resize(loopCount)
		for i in loopCount:
			booleans[i] = bool(randi() % 2)


	func _execute():
		for b in booleans:
# warning-ignore:unused_variable
			var x = "true" if b else "false"


	func teardown():
		booleans.clear()
