extends "res://AbstractTypeLine.gd"


var ints := []


func _create( count : int ) -> int:
	ints.resize(count)
	for i in ints.size():
		ints[i] = 3
	return OK


func _destroy():
	ints.resize(0)


func _compute():
	var _sum := 0
	for i in ints.size():
		_sum += ints[i]

