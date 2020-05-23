extends "res://addons/gut/test.gd"

const SerializerGd = preload("res://HierarchicalSerializer.gd")

var resourceExtension := ".tres" if OS.has_feature("debug") else ".res"


func test_saveToFile():
	var serializer = SerializerGd.new()

	var saveFileNoDir = "noDirectory"
	var err = serializer.saveToFile( saveFileNoDir )
	assert_eq( err, OK )
	assert_file_exists( saveFileNoDir + resourceExtension )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFileNoDir + resourceExtension )

	var saveFileUserDir = "user://ww/userDir.tres"
	err = serializer.saveToFile( saveFileUserDir )
	assert_eq( err, OK )
	assert_file_exists( saveFileUserDir )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFileUserDir )

	var saveFileWrongPath = "bah://wrong/Path.tres"
	err = serializer.saveToFile( saveFileWrongPath )
	assert_eq( err, ERR_CANT_CREATE )
	assert_file_does_not_exist( saveFileWrongPath )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFileWrongPath )


func test_saveVersion():
	var version := "0.4.3"
	var serializer = SerializerGd.new()
	var saveFile = "user://versionSave.tres"

	ProjectSettings.set_setting( "application/config/version", version )

	var err = serializer.saveToFile( saveFile )
	assert_file_exists( saveFile )
	assert_eq( err, OK )
	assert_eq( serializer.getVersion(), version )

	serializer.loadFromFile( saveFile )
	assert_eq( serializer.getVersion(), version )

	Directory.new().remove( saveFile )


