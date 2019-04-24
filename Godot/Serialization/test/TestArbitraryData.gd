extends "./TestBase.gd"

const SerializerGd = preload("res://HierarchicalSerializer.gd")


func _initialize():
	$"ToFloat".f = 2.3
	$"ToString".s = "arrayString"
	$"ToArray".i = 8
	$"ToArray".f = 4.4
	$"ToDict".s = "dictString"
	$"ToDict".f = 3.14


func _runTest():
	var result = SerializerGd.serialize( self )

	$"ToFloat".f = 0.0
	$"ToString".s = ""
	$"ToArray".i = 0
	$"ToArray".f = 0.0
	$"ToDict".s = ""
	$"ToDict".f = 0.0

	SerializerGd.deserialize( result, get_parent() )


func _validate():
	if (
		$"ToFloat".f == 2.3 and
		$"ToString".s == "arrayString" and
		$"ToArray".i == 8 and
		$"ToArray".f == 4.4 and
		$"ToDict".s == "dictString" and
		$"ToDict".f == 3.14
		):
		return 0
	else:
		return 1

