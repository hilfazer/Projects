extends "res://tests/GutTestBase.gd"

const MultiNodeGuardGd = preload("res://MultiNodeGuard.gd")


func test_create():
	var nodes = [Node.new(), Node2D.new()]
	var guard = MultiNodeGuardGd.new(nodes)

	assert_is(guard, Reference)
	assert_eq(guard.size(), nodes.size())

	var emptyGuard = MultiNodeGuardGd.new()

	assert_eq(emptyGuard.size(), 0)


func test_add():
	var nodes = [Node.new(), Node2D.new()]
	var guard = MultiNodeGuardGd.new(nodes)

	guard.add( Control.new() )

	assert_eq(guard.size(), nodes.size() + 1)


func test_release():
	pending()


func test_freeOnDestruction():
	pending()

func test_dontFreeNodesInTree():
	pending()
