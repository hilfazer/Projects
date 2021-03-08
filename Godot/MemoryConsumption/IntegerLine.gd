extends "res://TypeLine.gd"


var ints := []


func _create( count : int ):
	ints.resize(count)
	for i in ints.size():
		ints[i] = 3


func destroy():
	ints.resize(0)


func _compute():
	var _sum := 0
	for i in range(ints.size()):
		_sum += ints[i]

