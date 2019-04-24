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
	return -1 # test didn't run
	# 0 - success
	# 1 - failure


func _report():
	match _validate():
		-1:
			print( "Test %s unresolved" % [_testName] )
		0:
			print( "Test %s passed" % [_testName] )
		_:
			print( "Test %s failed" % [_testName] )
