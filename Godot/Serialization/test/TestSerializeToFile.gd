extends "./TestBase.gd"

const ToStringGd = preload("res://test/SerializeToString.gd")
const ToArrayGd = preload("res://test/SerializeToArray.gd")
const ToDictGd = preload("res://test/SerializeToDict.gd")

onready var toStringChild : ToStringGd = $"ToString"
onready var toArrayChild  : ToArrayGd = $"ToString/ToArray"
onready var toDictChild   : ToDictGd = $"ToDict"


func _initialize():
	toStringChild.s = "arrayString"
	toArrayChild.i = 8
	toArrayChild.f = 4.4
	toDictChild.s = "dictString"
	toDictChild.f = 3.14


func _runTest():
	var serializedData = SerializerGd.serialize( self )

	toStringChild.s = ""
	toArrayChild.i = 0
	toArrayChild.f = 0.0
	toDictChild.s = ""
	toDictChild.f = 0.0

	var serializer := SerializerGd.new()
	serializer.add( _testName, serializedData )
	var saveResult = serializer.saveToFile( _saveFilename, true )
	assert( saveResult == OK )

	serializer = SerializerGd.new()
	var loadResult = serializer.loadFromFile( _saveFilename )
	assert( loadResult == OK )
	var loadedData = serializer.getValue( _testName )

	# warning-ignore:return_value_discarded
	SerializerGd.deserialize( loadedData, get_parent() )


func _validate() -> int:
	var passed = \
		toStringChild.s == "arrayString" and \
		toArrayChild.i == 8 and \
		toArrayChild.f == 4.4 and \
		toDictChild.s == "dictString" and \
		toDictChild.f == 3.14

	return 0 if passed else 1
