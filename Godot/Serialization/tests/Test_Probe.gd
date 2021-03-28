extends "res://tests/GutTestBase.gd"

const Scene1Scn              = preload("res://tests/files/Scene1.tscn")
const SceneNoDeserializeGd   = preload("res://tests/files/NoDeserialize.tscn")
const ProbeGd                = preload("res://Probe.gd")


func test_probeValidSubtree():
	var scene1 = autofree( Scene1Scn.instance() )
	var probe = ProbeGd.scan( scene1 )
	assert_eq( probe.nodesNotInstantiable.size(), 0 )
	assert_eq( probe.nodesNoMatchingDeserialize.size(), 0 )


func test_noninstantiableSubtree():
	var scene1 = autofree( Scene1Scn.instance() )
	var node = Node.new()
	node.name = "CantInstance"
	scene1.add_child( node )
	var probe = ProbeGd.scan( scene1 )
	assert_eq( probe.nodesNotInstantiable.size(), 1 )
	assert_eq( probe.nodesNoMatchingDeserialize.size(), 0 )

	if probe.nodesNotInstantiable.size() == 1:
		assert_eq( probe.nodesNotInstantiable[0].name, "CantInstance" )


func test_nonserializableSubtree():
	var scene1 = autofree( SceneNoDeserializeGd.instance() )
	var probe = ProbeGd.scan( scene1 )
	assert_eq( probe.nodesNotInstantiable.size(), 0 )
	assert_eq( probe.nodesNoMatchingDeserialize.size(), 1 )

	if probe.nodesNoMatchingDeserialize.size() == 1:
		assert_eq( probe.nodesNoMatchingDeserialize[0].name, "NoDeserialize" )


func test_NonInstantiableOutsideTree():
	pending()
