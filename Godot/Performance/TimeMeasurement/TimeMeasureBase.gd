extends Node
class_name MeasureBase

var loopCount : int = 10_000 setget setLoopCount


func measureTime() -> int:
	var msec := OS.get_ticks_msec()
	_execute()
	return OS.get_ticks_msec() - msec


func _execute():
	assert(false)


func setup():
	pass


func teardown():
	pass


func setLoopCount(count : int):
	loopCount = count
