extends Node

var astar2d : AStar2D
var _probe : KinematicBody2D


func _init( fullAstar2d : AStar2D, shape : RectangleShape2D, mask : int ):
	astar2d = fullAstar2d
	_probe = _createAndSetupProbe(shape, mask)
	add_child(_probe)


static func _createAndSetupProbe(shape : RectangleShape2D, mask : int) -> KinematicBody2D:
	var probe := KinematicBody2D.new()
	probe.name = "probe"
	var collisionShape = CollisionShape2D.new()
	collisionShape.shape = shape
	probe.add_child(collisionShape)
	probe.collision_mask = mask
	return probe
