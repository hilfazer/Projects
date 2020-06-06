extends "res://addons/gut/test.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const NodeGuardGd            = preload("res://NodeGuard.gd")
const FiveNodeBranchScn      = preload("res://tests/FiveNodeBranch.tscn")
const PostDeserializeScn     = preload("res://tests/PostDeserialize.tscn")

const EPSILON = 0.00001

var resourceExtension := ".tres" if OS.has_feature("debug") else ".res"
var childrenNumberBeforeTest := 0


func _init():
	name = (get_script() as Script).resource_path.get_file()


func before_each():
	childrenNumberBeforeTest = get_child_count()


func after_each():
	assert_eq( childrenNumberBeforeTest, get_child_count() )


func test_saveAndLoadWithoutParent():
	var branch = FiveNodeBranchScn.instance()
	var serializer = SerializerGd.new()
	var saveFile = "user://saveAndLoadWithoutParent" + resourceExtension
	var branchKey = "5NodeBranch"

	yield( get_tree(), "idle_frame" )
	add_child( branch )

	branch.f = 4.4
	branch.s = "um"
	branch.get_node("Timer").f = 0.0
	branch.get_node("Timer/ColorRect").s = "7"
	branch.get_node("Bone2D/WorldEnvironment").f = 3.3
	branch.get_node("Bone2D/WorldEnvironment").i = 6

	var serializedBranch = serializer.serialize( branch )
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
	var guard : NodeGuardGd = serializer.deserialize( serialized, null )
	assert_almost_eq( guard.node.get('f'), 4.4, EPSILON )
	assert_eq( guard.node.get('s'), "um" )
	assert_almost_eq( guard.node.get_node("Timer").get('f'), 0.0, EPSILON )
	assert_eq( guard.node.get_node("Timer/ColorRect").get('s'), "7" )
	assert_almost_eq( guard.node.get_node("Bone2D/WorldEnvironment").get('f'), 3.3, EPSILON )
	assert_eq( guard.node.get_node("Bone2D/WorldEnvironment").get('i'), 6 )

	branch.queue_free()
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFile )


func test_saveAndLoadToExistingBranch():
	var branch = FiveNodeBranchScn.instance()
	var serializer = SerializerGd.new()
	var saveFile = "user://saveAndLoadToExistingBranch.tres"
	var branchKey = "5NodeBranch"

	yield( get_tree(), "idle_frame" )
	add_child( branch )

	branch.s = "um"
	branch.get_node("Timer").f = 0.0
	branch.get_node("Timer/ColorRect").s = "7"

	var serializedBranch = serializer.serialize( branch )
	serializer.addSerialized( branchKey, serializedBranch )
	var err = serializer.saveToFile( saveFile )
	assert_eq( err, OK )
	assert_file_exists( saveFile )

	serializer = SerializerGd.new()
	err = serializer.loadFromFile( saveFile.get_basename() )
	assert_eq( err, OK )
	assert_true( serializer.hasKey(branchKey) )

	branch.get_node("Timer").f = 99.99
	branch.get_node("Timer/ColorRect").s = "7655"

	var serialized : Array = serializer.getSerialized( branchKey )
	assert_gt( serialized.size(), 0 )
	var node : Node = serializer.deserialize( serialized, self ).node
	assert_eq( node, branch )
	assert_eq( node.get('s'), "um" )
	assert_almost_eq( node.get_node("Timer").get('f'), 0.0, EPSILON )
	assert_eq( node.get_node("Timer/ColorRect").get('s'), "7" )

	branch.queue_free()
	remove_child( branch )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFile )


func test_saveAndLoadToNonexistingBranch():
	var branch = FiveNodeBranchScn.instance()
	var serializer = SerializerGd.new()
	var saveFile = "user://saveAndLoadToNonexistingBranch.tres"
	var branchKey = "5NodeBranch"

	yield( get_tree(), "idle_frame" )
	add_child( branch )

	branch.s = "v"
	branch.get_node("Timer").f = 0.06
	branch.get_node("Timer/ColorRect").s = "88"

	var serializedBranch = serializer.serialize( branch )
	serializer.addSerialized( branchKey, serializedBranch )
	var err = serializer.saveToFile( saveFile )
	assert_eq( err, OK )
	assert_file_exists( saveFile )

	branch.queue_free()
	remove_child( branch )
	assert( not is_a_parent_of( branch ) )

	err = serializer.loadFromFile( saveFile.get_basename() )
	assert_eq( err, OK )
	assert_true( serializer.hasKey(branchKey) )

	var serialized : Array = serializer.getSerialized( branchKey )
	assert_gt( serialized.size(), 0 )

	var childrenNumber := get_child_count()
	var node : Node = serializer.deserialize( serialized, self ).node
	assert_eq( childrenNumber + 1, get_child_count() )
	assert_eq( node.get('s'), "v" )
	assert_almost_eq( node.get_node("Timer").get('f'), 0.06, EPSILON )
	assert_eq( node.get_node("Timer/ColorRect").get('s'), "88" )

	node.queue_free()
	remove_child( node )
# warning-ignore:return_value_discarded
	Directory.new().remove( saveFile )


func test_postDeserialize():
	var serializer = SerializerGd.new()
	var branchGuard := NodeGuardGd.new( PostDeserializeScn.instance() )
	branchGuard.node.set("i", 16)

	var serialized : Array = serializer.serialize( branchGuard.node )
	var deserialized : Node = serializer.deserialize( serialized, self ).node

	assert_eq( deserialized.get("i"), 16 )
	assert_eq( deserialized.get("ii"), 16 )

	deserialized.queue_free()
	remove_child( deserialized )


func test_deserializeNoninstantiable():
	pending()


func test_dynamicTree():
	pending()
