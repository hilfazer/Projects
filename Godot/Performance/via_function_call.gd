extends "res://Base.gd"


export var loopCount : int = 1000000


func _execute():
	for i in loopCount:
		_function()


func _function():
# warning-ignore:unused_variable
	var irrelevant : float = tan(sin(randf())) * cos(randf())
