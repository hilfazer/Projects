extends "res://Base.gd"


export var loopCount : int = 1000000


func _execute():
	for i in loopCount:
	# warning-ignore:unused_variable
		var irrelevant : float = tan(sin(randf())) * cos(randf())
