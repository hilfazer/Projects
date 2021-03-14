extends "res://TimeMeasurement/TimeMeasureBase.gd"


export var loopCount : int = 10_000_000


func _execute():
	var _a
	for i in loopCount:
		_a = $"TimeTaken".text
