extends "res://addons/gut/test.gd"

const SerializerGd = preload("res://HierarchicalSerializer.gd")


func test_saveToFile():
	var serializer = SerializerGd.new()

	var saveFileNoDir = "emptySave"
	var err = serializer.saveToFile( saveFileNoDir )
	assert_eq( err, OK )
	assert_file_exists( saveFileNoDir + ".tres" )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFileNoDir + ".tres" )

	var saveFileUserDir = "user://ww/userDir.tres"
	err = serializer.saveToFile( saveFileUserDir )
	assert_eq( err, OK )
	assert_file_exists( saveFileUserDir )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFileUserDir )

	var saveFileWrongPath = "bah://wrong/Path.tres"
	err = serializer.saveToFile( saveFileWrongPath )
	assert_ne( err, OK )
	assert_file_does_not_exist( saveFileWrongPath )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFileWrongPath )

