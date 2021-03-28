tool
extends "./TimeMeasureScene.gd"


func _ready():
# warning-ignore:return_value_discarded
	addMeasure(ForLoop.new(),     "ForLoop")
# warning-ignore:return_value_discarded
	addMeasure(WhileLoop.new(),   "WhileLoop")
# warning-ignore:return_value_discarded
	addMeasure(RolledFor.new(),   "RolledFor")
# warning-ignore:return_value_discarded
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

		for i in loopCount / 2:
			for j in loopCount / 2:
				for k in [0, 1]:
					array[2*k] += 1
					array[2*k + 1] += 1


class UnrolledFor extends MeasureBase:
	func _execute():
		var array := [0, 0, 0, 0]

		for i in loopCount / 2:
			for j in loopCount / 2:
				array[0] += 1
				array[1] += 1
				array[2] += 1
				array[3] += 1
