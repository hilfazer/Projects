tool
extends "res://TimeMeasurement/TimeMeasureBase.gd"

const LoopCount = 10_000


func _execute():
	var x = 0
	var y = 0

	while x < LoopCount:
		y = 0
		while y < LoopCount:
			pass
			y += 1
		x += 1
