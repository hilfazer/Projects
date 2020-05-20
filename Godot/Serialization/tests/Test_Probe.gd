extends "res://addons/gut/test.gd"

const SerializerGd = preload("res://HierarchicalSerializer.gd")
const Scene1Scn = preload("res://tests/Scene1.tscn")
const SceneNoDeserializeGd = preload("res://tests/SceneNoDeserialize.tscn")


func test_probeValidSubtree():
	var scene1 = Scene1Scn.instance()
	var probe = SerializerGd.Probe.new( scene1 )
	assert_eq( probe.getNotInstantiableNodes().size(), 0 )
	assert_eq( probe.getNodesNoMatchingDeserialize().size(), 0 )
	scene1.free()


func test_noninstantiableSubtree():
	var scene1 = Scene1Scn.instance()
	scene1.add_child( Node.new() )
	var probe = SerializerGd.Probe.new( scene1 )
	assert_eq( probe.getNotInstantiableNodes().size(), 1 )
	assert_eq( probe.getNodesNoMatchingDeserialize().size(), 0 )
	scene1.free()


func test_nonserializableSubtree():
	var scene1 = SceneNoDeserializeGd.instance()
	var probe = SerializerGd.Probe.new( scene1 )
	assert_eq( probe.getNotInstantiableNodes().size(), 0 )
	assert_eq( probe.getNodesNoMatchingDeserialize().size(), 1 )
	scene1.free()
