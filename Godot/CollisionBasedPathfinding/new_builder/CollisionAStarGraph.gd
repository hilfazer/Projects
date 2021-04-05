extends Node

const FunctionsGd =          preload("./CollisionAStarFunctions.gd")
const PointsDataGd =         preload("./PointsData.gd")

var astar2d : AStar2D
var _probe : KinematicBody2D


func _init(
		  pointsData : PointsDataGd.PointsData
		, pts2ids : Dictionary
		, diagonal : bool
		):

	name = "Graph"
	astar2d = FunctionsGd.createFullyConnectedAStar(pointsData, pts2ids, diagonal)


func initializeProbe(shape : RectangleShape2D, mask : int) -> void:
	_probe = _createAndSetupProbe__(shape, mask)
	add_child(_probe)


func updateGraph(points : Array) -> void:
	if _probe == null:
		return

	for pt in points:
		#assert(pt in astar2d.get_points())
		pass


static func _createAndSetupProbe__(shape : RectangleShape2D, mask : int) -> KinematicBody2D:
	var probe := KinematicBody2D.new()
	probe.name = "Probe"
	var collisionShape = CollisionShape2D.new()
	collisionShape.name = "CollisionShape2D"
	collisionShape.shape = shape
	probe.add_child(collisionShape)
	probe.collision_mask = mask
	return probe
