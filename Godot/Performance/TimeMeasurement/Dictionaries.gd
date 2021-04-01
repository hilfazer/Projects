tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(DictionaryDeepCopy.new(), "DictionaryDeepCopy")
	addMeasure(DictionaryShallowCopy.new(), "DictionaryShallowCopy")


class DictionaryDeepCopy extends MeasureBase:
	var _original := {}
	var _duplicate := {}

	func setup():
		for i in loopCount:
			_original[i] = str(i)


	func _execute():
		_duplicate = _original.duplicate(true)


	func teardown():
		_original.clear()
		_duplicate.clear()


class DictionaryShallowCopy extends MeasureBase:
	var _original := {}
	var _duplicate := {}

	func setup():
		for i in loopCount:
			_original[i] = str(i)


	func _execute():
		_duplicate = _original.duplicate(false)


	func teardown():
		_original.clear()
		_duplicate.clear()
