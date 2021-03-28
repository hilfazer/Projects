tool
extends "./TimeMeasureScene.gd"


func _ready():
# warning-ignore:return_value_discarded
	addMeasure(ForLoop.new(), "ForLoop")
# warning-ignore:return_value_discarded
	addMeasure(WhileLoop.new(),   "WhileLoop")


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
