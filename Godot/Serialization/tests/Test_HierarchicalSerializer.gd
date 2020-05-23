extends "res://addons/gut/test.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const FiveNodeBranchScn      = preload("res://tests/FiveNodeBranch.tscn")
const NodeGuardGd            = preload("res://NodeGuard.gd")

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

	err = serializer.loadFromFile( saveFile )
	assert_eq( err, OK )
	assert_eq( serializer.getVersion(), version )

# warning-ignore:return_value_discarded
	Directory.new().remove( saveFile )


func test_saveUserData():
	var serializer = SerializerGd.new()
	var saveFile = "user://userDataSave.tres"
	var dict = { "d":5, 1:2, 3:4.5678 }
	var arr = [0, Vector2(1.1, 2.2), 8, null]

	serializer.userData["DICT"] = dict
	serializer.userData["ARR"] = arr
	var err = serializer.saveToFile( saveFile )
	assert_file_exists( saveFile )
	assert_eq( err, OK )

	serializer = SerializerGd.new()

	err = serializer.loadFromFile( saveFile )
	assert_eq( err, OK )

	assert_almost_eq( serializer.userData["DICT"][3], dict[3], 0.00001 )
	assert_eq( serializer.userData["DICT"]["d"], dict["d"] )
	assert_eq( serializer.userData["ARR"][1], arr[1] )
	assert_eq( serializer.userData["ARR"][3], arr[3] )

# warning-ignore:return_value_discarded
	Directory.new().remove( saveFile )


func test_saveFiveNodeBranch():
	var branch = FiveNodeBranchScn.instance()
	var serializer = SerializerGd.new()
	var saveFile = "user://branch" + resourceExtension
	var branchKey = "KEY"

	yield( get_tree(), "idle_frame" )
	add_child( branch )

	branch.f = 4.4
	branch.s = "um"
	branch.get_node("Timer").f = 0.0
	branch.get_node("Timer/ColorRect").s = "7"
	branch.get_node("Bone2D/WorldEnvironment").f = 3.3
	branch.get_node("Bone2D/WorldEnvironment").i = 6

	var serializedBranch = SerializerGd.serialize( branch )
	serializer.addSerialized( branchKey, serializedBranch )
	var err = serializer.saveToFile( saveFile )
	assert_eq( err, OK )
	assert_file_exists( saveFile )

	serializer = SerializerGd.new()
	err = serializer.loadFromFile( saveFile.get_basename() )
	assert_eq( err, OK )
	assert_true( serializer.hasKey(branchKey) )

	var serialized : Array = serializer.getSerialized( branchKey )
	assert_gt( serialized.size(), 0 )
	var guard : NodeGuardGd = SerializerGd.deserialize( serialized, null )
	assert_eq( guard.node.get('f'), 4.4 )
	assert_eq( guard.node.get('s'), "um" )
	assert_eq( guard.node.get_node("Timer").get('f'), 0.0 )
	assert_eq( guard.node.get_node("Timer/ColorRect").get('s'), "7" )
	assert_eq( guard.node.get_node("Bone2D/WorldEnvironment").get('f'), 3.3 )
	assert_eq( guard.node.get_node("Bone2D/WorldEnvironment").get('i'), 6 )

	branch.queue_free()
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFile )

