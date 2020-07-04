extends "res://tests/GutTestBase.gd"

const SerializerGd           = preload("res://HierarchicalSerializer.gd")
const NodeGuardGd            = preload("res://NodeGuard.gd")
const FiveNodeBranchScn      = preload("res://tests/files/FiveNodeBranch.tscn")

const PERSISTENT_GROUP = "persistent"


func test_setCustomIsSerializable():
	var serializer = SerializerGd.new()
	serializer.setCustomIsNodeSerializable( DetectSerializeMethodFunctor.new() )

	var branch = FiveNodeBranchScn.instance()
	var saveFile = _createDefaultTestFilePath("tres")
	var branchKey = "5NodeBranch"

	yield( get_tree(), "idle_frame" )
	add_child( branch )

	branch.f = 4.4
	branch.s = "um"
	branch.get_node("Timer").f = 0.0
	branch.get_node("Timer/ColorRect").s = "7d"
	branch.get_node("Bone2D/Label").f = 3.3
	branch.get_node("Bone2D/Label").i = 6

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
	assert_almost_eq( guard.node.get_node("Bone2D/Label").get('f'), 3.3, EPSILON )
	assert_eq( guard.node.get_node("Bone2D/Label").get('i'), 6 )
	guard.setNode(null)


func test_setCustomIsSerializableWithGroup():
	var branch = autofree( FiveNodeBranchScn.instance() )

	var saveFile = _createDefaultTestFilePath( "tres" )
	var branchKey = "nested5NodeBranch"

	yield( get_tree(), "idle_frame" )
	var outerBranch = branch.duplicate()
	add_child( outerBranch )
	$"Spatial/Timer/ColorRect".set('s', "dont_serialize")

	var innerBranch = branch.duplicate()
	outerBranch.get_node("Bone2D/Label").add_child( innerBranch )
	innerBranch.get_node("Timer/ColorRect").set('s', "do_serialize")
	innerBranch.get_node("Timer/ColorRect").add_to_group( PERSISTENT_GROUP )

	var serializer = SerializerGd.new()
	serializer.setCustomIsNodeSerializable( DetectPersistentGroupFunctor.new() )
	serializer.addSerialized( branchKey, serializer.serialize( outerBranch ) )
	serializer.saveToFile( saveFile )

	outerBranch.free()
	assert_freed( outerBranch, "outerBranch freed" )

	serializer.loadFromFile( saveFile )
	serializer.getSerialized( branchKey )
	var deserialized = serializer.getSerialized( branchKey )
	serializer.deserialize( deserialized, self )

	assert_eq( $"Spatial/Bone2D/Label/Spatial/Timer/ColorRect".get('s'), "do_serialize")
	assert_ne( $"Spatial/Timer/ColorRect".get('s'), "dont_serialize" )


class DetectSerializeMethodFunctor extends Reference:
	func is_serializable( node : Node ) -> bool:
		return node.has_method( SerializerGd.SERIALIZE )


class DetectPersistentGroupFunctor extends Reference:
	func is_serializable( node : Node ) -> bool:
		return node.is_in_group( PERSISTENT_GROUP )
