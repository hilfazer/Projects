extends "./TestBase.gd"

const ToFloatGd = preload("res://test/SerializeToFloat.gd")
const ToStringGd = preload("res://test/SerializeToString.gd")
const ToArrayGd = preload("res://test/SerializeToArray.gd")
const ToDictGd = preload("res://test/SerializeToDict.gd")

onready var toFloatChild  : ToFloatGd = $"ToFloat"
onready var toStringChild : ToStringGd = $"ToString"
onready var toArrayChild  : ToArrayGd = $"ToArray"
onready var toDictChild   : ToDictGd = $"ToDict"

func _initialize():
	toFloatChild.f = 2.3
	toStringChild.s = "arrayString"
	toArrayChild.i = 8
	toArrayChild.f = 4.4
	toDictChild.s = "dictString"
	toDictChild.f = 3.14


func _runTest():
	var result = SerializerGd.serialize( self )

	toFloatChild.f = 0.0
	toStringChild.s = ""
	toArrayChild.i = 0
	toArrayChild.f = 0.0
	toDictChild.s = ""
	toDictChild.f = 0.0

	SerializerGd.deserialize( result, get_parent() )


func _validate() -> int:
	if (
		toFloatChild.f == 2.3 and
		toStringChild.s == "arrayString" and
		toArrayChild.i == 8 and
		toArrayChild.f == 4.4 and
		toDictChild.s == "dictString" and
		toDictChild.f == 3.14
		):
		return 0
	else:
		return 1

