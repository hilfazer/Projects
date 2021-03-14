extends "res://TimeMeasurement/TimeMeasureBase.gd"


export var loopCount : int = 10_000_000

onready var node = $"TimeTaken"


func _execute():
	var _a
	for i in loopCount:
		_a = node.text
