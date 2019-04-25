extends Node

const SerializerGd = preload("res://HierarchicalSerializer.gd")

onready var _testName = name
#warning-ignore:unused_class_variable
onready var _saveFilename = "res://save/" + _testName + ".save"


func _ready():
	call_deferred("_initialize")
	call_deferred("_runTest")
	call_deferred("_report")


func _initialize():
	pass


func _runTest():
	pass


func _validate() -> int:
	return 1

	# 0 - success
	# other values - failure


func _report():
	match _validate():
		0:
			print( "Test %-60s PASSED" % [_testName] )
		_:
			print( "Test %-60s FAILED" % [_testName] )
