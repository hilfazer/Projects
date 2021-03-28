tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(ForLoop.new(),     "ForLoop")
	addMeasure(WhileLoop.new(),   "WhileLoop")
	addMeasure(RolledFor.new(),   "RolledFor")
	addMeasure(UnrolledFor.new(), "UnrolledFor")


class ForLoop extends MeasureBase:
	func _execute():
		for i in loopCount:
			for j in loopCount:
				pass


class WhileLoop extends MeasureBase:
	func _execute():
		var x = 0
		var y = 0

		while x < loopCount:
			y = 0
			while y < loopCount:
				pass
				y += 1
			x += 1


class RolledFor extends MeasureBase:
	func _execute():
		var array := [0, 0, 0, 0]

		for i in int(loopCount / 2.0):
			for j in int(loopCount / 2.0):
				for k in [0, 1]:
					array[2*k] += 1
					array[2*k + 1] += 1


class UnrolledFor extends MeasureBase:
	func _execute():
		var array := [0, 0, 0, 0]

		for i in int(loopCount / 2.0):
			for j in int(loopCount / 2.0):
				array[0] += 1
				array[1] += 1
				array[2] += 1
				array[3] += 1
