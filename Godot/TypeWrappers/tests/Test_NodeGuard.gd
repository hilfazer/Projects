extends "res://tests/files/GutTestBase.gd"

const NodeGuardGd = preload("res://NodeGuard.gd")


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
	var node2 = AnimationPlayer.new()
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

	var node1 = add_child_autoqfree(Node.new())
	node1.add_child( Node2D.new() )
	_guardNode( node1 )
	assert_not_freed( node1, "node1" )


static func _guardNode( node : Node ):
	var guard = NodeGuardGd.new()
	guard.setNode( node )

