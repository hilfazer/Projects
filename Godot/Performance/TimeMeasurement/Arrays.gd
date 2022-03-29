tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(ArrayDoubleIndexing.new(), "ArrayDoubleIndexing")
	addMeasure(ArraySingleIndexing.new(), "ArraySingleIndexing")
	addMeasure(ArrayWithEnumKeys.new(), "ArrayWithEnumKeys")
	addMeasure(DictionaryWithStringKeys.new(), "DictionaryWithStringKeys")


class BaseWith2DArray extends MeasureBase:
	var array = []

	func setLoopCount(count : int):
		.setLoopCount(count)

		var inner = []
		inner.resize(sqrt(loopCount))
		array.resize(sqrt(loopCount))

		for i in array.size():
			array[i] = inner.duplicate()


class ArrayDoubleIndexing extends BaseWith2DArray:
	func _execute():
		for i in array.size():
			for j in array[i].size():
				var _bag = array[i][j]


class ArraySingleIndexing extends BaseWith2DArray:
	func _execute():
		for i in array.size():
			var inner : Array = array[i]
			for j in inner.size():
				var _bag = inner[j]


enum Keys { One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten }
const StringKeys = ['One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten']


class ArrayWithEnumKeys extends MeasureBase:
	var array := []
	var keysToCheck := []


	func _init():
		for i in Keys.size():
			array.append(StringKeys[i])


	func setLoopCount(count : int):
		.setLoopCount(count)

		keysToCheck.resize(count)
		for i in count:
			keysToCheck[i] = Keys.values()[ randi() % Keys.size() ]


	func _execute():
		for key in keysToCheck:
# warning-ignore:standalone_expression
			array[key]


class DictionaryWithStringKeys extends MeasureBase:
	var dict := {}
	var keysToCheck := []


	func _init():
		for i in Keys.size():
			dict[StringKeys[i]] = StringKeys[i]


	func setLoopCount(count : int):
		.setLoopCount(count)

		keysToCheck.resize(count)
		for i in count:
			keysToCheck[i] = StringKeys[ randi() % StringKeys.size() ]


	func _execute():
		for key in keysToCheck:
# warning-ignore:standalone_expression
			dict[key]
