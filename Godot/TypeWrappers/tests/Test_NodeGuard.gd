extends "res://addons/gut/test.gd"

const NodeGuardGd = preload("res://NodeGuard.gd")

var orphanCount : int


func before_each():
	orphanCount = int( Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )


func after_each():
	assert_eq( orphanCount, Performance.get_monitor( Performance.OBJECT_ORPHAN_NODE_COUNT ) )


func test_create():
	var node = Node.new()
	var guard = NodeGuardGd.new( node )
	assert_is( guard, Reference )
	assert_eq( guard.node, node )


func test_setNode():
	var node = Node.new()
	var guard = NodeGuardGd.new()
	guard.setNode( node )
	assert_eq( guard.node, node )


func test_resetNode():
	var node1 = Node.new()
	var guard = NodeGuardGd.new()
	guard.setNode( node1 )
	var node2 = Node.new()
	guard.setNode( node2 )
	assert_freed( node1, "node1" )
	assert_not_freed( node2, "node2" )
	node2.free()


func test_release():
	var node1 = Node.new()
	var guard = NodeGuardGd.new()
	guard.setNode( node1 )
	guard.release()
	assert_not_freed( node1, "node1" )
	node1.free()


func test_freeOnDestruction():
	var node1 = Node.new()
	node1.add_child( Node2D.new() )
	_guardNode( node1 )
	assert_freed( node1, "node1" )


func test_dontFreeNodesInTree():
	yield(get_tree(), "idle_frame")

	var node1 = Node.new()
	node1.add_child( Node2D.new() )
	$"/root".add_child( node1 )
	_guardNode( node1 )
	assert_not_freed( node1, "node1" )
# warning-ignore:standalone_expression
	is_instance_valid( node1 ) && node1.queue_free()


static func _guardNode( node : Node ):
	var guard = NodeGuardGd.new()
	guard.setNode( node )



