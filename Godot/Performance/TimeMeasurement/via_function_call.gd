tool
extends "./TimeMeasureBase.gd"


export var loopCount : int = 10_000_000


func _execute():
	for i in loopCount:
		_function()


func _function():
# warning-ignore:unused_variable
	var irrelevant : float = tan(sin(randf())) * cos(randf())

