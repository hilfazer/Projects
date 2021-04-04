extends Node

var astar2d : AStar2D
var _tester : KinematicBody2D


func _init( fullAstar2d : AStar2D, shape : RectangleShape2D, mask : int ):
	astar2d = fullAstar2d
	_tester = _createAndSetupTester(shape, mask)
	add_child(_tester)


static func _createAndSetupTester(shape : RectangleShape2D, mask : int) -> KinematicBody2D:
	var tester := KinematicBody2D.new()
	var collisionShape = CollisionShape2D.new()
	collisionShape.shape = shape
	tester.add_child(collisionShape)
	tester.collision_mask = mask
	return tester
