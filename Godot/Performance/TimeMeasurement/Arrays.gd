tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(ArrayDoubleIndexing.new(), "ArrayDoubleIndexing")
	addMeasure(ArraySingleIndexing.new(), "ArraySingleIndexing")


class BaseWithArray extends MeasureBase:
	var array = []

	func setLoopCount(count : int):
		.setLoopCount(count)

		var inner = []
		inner.resize(sqrt(loopCount))
		array.resize(sqrt(loopCount))

		for i in array.size():
			array[i] = inner.duplicate()


class ArrayDoubleIndexing extends BaseWithArray:
	func _execute():
		for i in array.size():
			for j in array[i].size():
				var _bag = array[i][j]


class ArraySingleIndexing extends BaseWithArray:
	func _execute():
		for i in array.size():
			var inner : Array = array[i]
			for j in inner.size():
				var _bag = inner[j]
