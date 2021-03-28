tool
extends "./TimeMeasureScene.gd"


func _ready():
	addMeasure(ViaFunctionCall.new(), "ViaFunctionCall")
	addMeasure(ViaInlineCode.new(),   "ViaInlineCode")


class ViaFunctionCall extends MeasureBase:
	func _execute():
		for i in loopCount:
			_function()


	func _function():
	# warning-ignore:unused_variable
		var irrelevant : float = tan(sin(randf())) * cos(randf())


class ViaInlineCode extends MeasureBase:
	func _execute():
		for i in loopCount:
		# warning-ignore:unused_variable
			var irrelevant : float = tan(sin(randf())) * cos(randf())
