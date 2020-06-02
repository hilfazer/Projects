extends "res://addons/gut/test.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const FiveNodeBranchScn      = preload("res://tests/FiveNodeBranch.tscn")
const NodeGuardGd            = preload("res://NodeGuard.gd")

const EPSILON = 0.00001

var orphanCount : int


func before_each():
	orphanCount = int( Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )


func after_each():
	assert_eq( orphanCount, Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )


func test_setCustomIsSerializable():
	var serializer = SerializerGd.new()
	serializer.setCustomIsNodeSerializable( IsSerializableFunctor.new() )

	var branch = FiveNodeBranchScn.instance()
	var saveFile = "user://saveAndLoadWithoutParent.tres"
	var branchKey = "5NodeBranch"

	yield( get_tree(), "idle_frame" )
	add_child( branch )

	branch.f = 4.4
	branch.s = "um"
	branch.get_node("Timer").f = 0.0
	branch.get_node("Timer/ColorRect").s = "7d"
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
	assert_eq( guard.node.get_node("Timer/ColorRect").get('s'), "7d" )
	assert_almost_eq( guard.node.get_node("Bone2D/WorldEnvironment").get('f'), 3.3, EPSILON )
	assert_eq( guard.node.get_node("Bone2D/WorldEnvironment").get('i'), 6 )


func test_setCustomIsSerializableWithGroup():
	pending()


class IsSerializableFunctor extends Reference:
	func is_serializable( node : Node ) -> bool:
		return node.has_method( SerializerGd.SERIALIZE )
