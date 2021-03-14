tool
extends "res://AbstractTypeLine.gd"


var dicts := []


func _create( count : int ) -> int:
	dicts.resize(count)
	for i in dicts.size():
		dicts[i] = Dictionary()
	return OK


func _destroy():
	dicts.clear()


func _compute():
	var _sum := 0
	for i in dicts.size():
		_sum += dicts[i].size()

