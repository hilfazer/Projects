tool
extends "res://AbstractTypeLine.gd"


var floats := []


func _create( count : int ) -> int:
	floats.resize(count)
	for i in count:
		floats[i] = 2.2
	return OK


func _destroy():
	floats.clear()


func _compute():
	var _sum := 0
	for fl in floats:
		_sum += fl

