tool
extends "res://AbstractTypeLine.gd"


var arrays := []


func _create( count : int ) -> int:
	arrays.resize(count)
	for i in arrays.size():
		arrays[i] = Array()
	return OK


func _destroy():
	arrays.clear()


func _compute():
	var _sum := 0
	for i in arrays.size():
		_sum += arrays[i].size()

