extends Node

const FunctionsGd =          preload("./StaticFunctions.gd")
const PointsDataGd =         preload("./PointsData.gd")

var astar2d : AStar2D
var _probe : KinematicBody2D
var _neighbourOffsets : Array
var _points2ids : Dictionary

var _shapeParams : Physics2DShapeQueryParameters


signal predelete()


func _init(
		  pointsData : PointsDataGd.PointsData
		, pts2ids : Dictionary
		, neighbourOffsets : Array
		):

	assert(neighbourOffsets.size() in [2, 4])
	assert(typeof(neighbourOffsets[1]) == TYPE_VECTOR2)
	name = "Graph"
	var diagonal = true if neighbourOffsets.size() == 4 else false
	astar2d = FunctionsGd.createFullyConnectedAStar(pointsData, pts2ids, diagonal)
	_neighbourOffsets = neighbourOffsets
	_points2ids = pts2ids


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal("predelete")


func initializeProbe(shape : RectangleShape2D, mask : int) -> void:
	_probe = _createAndSetupProbe__(shape, mask)
	add_child(_probe)
	_shapeParams = _createShapeQueryParameters(_probe)


func updateGraph(points :Array) -> void:
	if _probe == null:
		return

	var ED_points = findEnabledAndDisabledPoints(points, _probe, _shapeParams)
	for pt in ED_points[0]:
		astar2d.set_point_disabled(_points2ids[pt], false)

	for pt in ED_points[1]:
		astar2d.set_point_disabled(_points2ids[pt], true)


	#TODO connections


static func makeNeighbourOffsets(step :Vector2, diagonal :bool) -> Array:
	var offsets := [Vector2(step.x, 0), Vector2(0, step.y)]
	if diagonal:
		offsets += [Vector2(step.x, -step.y),Vector2(step.x, step.y)]
	return offsets


static func findEnabledAndDisabledPoints(
		points :Array, probe :KinematicBody2D, params :Physics2DShapeQueryParameters) -> Array:

	var enabledAndDisabled := [[], []]
	var spaceState := probe.get_world_2d().direct_space_state
	var transform := Transform2D()

	for pt in points:
		transform.origin = pt
		params.transform = transform
		var isValidPlace = spaceState.intersect_shape(params, 1).empty()
		enabledAndDisabled[ int(!isValidPlace) ].append(pt)

	return enabledAndDisabled


static func _createShapeQueryParameters(probe) -> Physics2DShapeQueryParameters:
	var params := Physics2DShapeQueryParameters.new()
	params.collide_with_bodies = true
	params.collision_layer = probe.collision_mask # Physics2DShapeQueryParameters seem to need this to work
	params.transform = probe.transform
	params.exclude = [probe] + probe.get_collision_exceptions()
	params.shape_rid = probe.get_node("CollisionShape2D").shape.get_rid()
	return params


static func _createAndSetupProbe__(shape : RectangleShape2D, mask : int) -> KinematicBody2D:
	var probe := KinematicBody2D.new()
	probe.name = "Probe"
	var collisionShape = CollisionShape2D.new()
	probe.add_child(collisionShape)
	collisionShape.name = "CollisionShape2D"
	collisionShape.shape = shape
	probe.collision_mask = mask
	return probe
