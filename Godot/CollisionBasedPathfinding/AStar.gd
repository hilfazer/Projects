extends Node

const NodeGuard = preload("./NodeGuard.gd")

const ShapeName := "Shape"
const Epsilon := 0.0001

class PointsData:
	var topLeftPoint : Vector2
	var xCount : int
	var yCount : int


var _step : Vector2
var _offsets := []
var _boundingRect : Rect2
var _pointsData : PointsData
var _astar := AStar.new()
var _testerShape := NodeGuard.new()

var _space : Physics2DDirectSpaceState
var _shapeParams : Physics2DShapeQueryParameters

var create : bool = false

signal graphCreated()


func _physics_process(_delta):
	if !create:
		return

	createGraph()
	create = false


func initialize( step : Vector2, boundingRect : Rect2, shape2d : CollisionShape2D ):
	if _boundingRect:
		print ("%s already initialized" % [self.get_path()])
		return

	if not shape2d:
		print("shape is null")
		return

	_setStep(step)
	_boundingRect = boundingRect
	_pointsData = _pointsDataFromRect( step, boundingRect )
	_testerShape.setNode( shape2d.duplicate() )
	_testerShape.node.name = ShapeName


func createGraph():
	assert(_testerShape.node != null)
	assert(is_inside_tree())

	var startTime := OS.get_system_time_msecs()

	var tester := KinematicBody2D.new()
	tester.add_child(_testerShape.release())
	add_child(tester)

	var pointIds : Dictionary = _calculateIdsForPoints(_pointsData, _boundingRect)

	_space = tester.get_world_2d().direct_space_state
	_shapeParams = Physics2DShapeQueryParameters.new()
	_shapeParams.collide_with_bodies = true
	_shapeParams.collision_layer = tester.collision_layer
	_shapeParams.transform = tester.transform
	_shapeParams.exclude = [tester]
	_shapeParams.shape_rid = tester.get_node(ShapeName).shape.get_rid()


	for x in _pointsData.xCount:
		for y in _pointsData.yCount:
			var originPoint := Vector2(_pointsData.topLeftPoint.x + x*_step.x \
				, _pointsData.topLeftPoint.y + y*_step.y)

			var allow : Array = _testMovementFrom(originPoint, tester)

			if allow.size() == 0:
				continue

			_astar.add_point( pointIds[originPoint] \
				, Vector3(originPoint.x, originPoint.y, 0.0) )

			for point in allow:
				_astar.add_point( pointIds[point] \
					, Vector3(point.x, point.y, 0.0) )
				_astar.connect_points(pointIds[originPoint], pointIds[point])


	remove_child(tester)
	tester.queue_free()
	emit_signal('graphCreated')

	print('elapsed : %s msec' % (OS.get_system_time_msecs() - startTime))


func getBoundingRect() -> Rect2:
	return _boundingRect


func getPointsData() -> PointsData:
	return _pointsData


func getAStarPoints2D() -> Array:
	var pointArray := []
	for id in _astar.get_points():
		var point3d : Vector3 = _astar.get_point_position(id)
		pointArray.append(Vector2(point3d.x, point3d.y))

	return pointArray


func getAStarEdges2D() -> Array:
	var edges := []
	for id in _astar.get_points():
		var point3d : Vector3 = _astar.get_point_position(id)
		var connections : PoolIntArray = _astar.get_point_connections(id)
		for id_to in connections:
			var pointTo3d : Vector3 = _astar.get_point_position(id_to)
			edges.append(
				[ Vector2(point3d.x, point3d.y), Vector2(pointTo3d.x, pointTo3d.y) ] )

	return edges


func _setStep(step : Vector2):
	_step = step
	_offsets = [
		  Vector2(_step.x, -_step.y)
		, Vector2(_step.x, 0)
		, Vector2(_step.x, _step.y)
		, Vector2(0, _step.y)
		]


func _pointsDataFromRect( step : Vector2, rect : Rect2 ) -> PointsData:
	var data = PointsData.new()

	data.topLeftPoint.x = stepify(rect.position.x + step.x/2, step.x)
	var xLastPoint : int = int((rect.position.x + rect.size.x -1) / step.x) * int(step.x)
	data.xCount = int((xLastPoint - data.topLeftPoint.x) / step.x) + 1

	data.topLeftPoint.y = stepify(rect.position.y + step.y/2, step.y)
	var yLastPoint : int = int((rect.position.y + rect.size.y -1) / step.y) * int(step.y)
	data.yCount = int((yLastPoint - data.topLeftPoint.y) / step.y) + 1

	return data


func _calculateIdsForPoints(data : PointsData, boundingRect : Rect2) -> Dictionary:
	var pointsToIds := Dictionary()

	for x in data.xCount:
		for y in data.yCount:
			var point = Vector2(data.topLeftPoint.x + x*_step.x, data.topLeftPoint.y + y*_step.y)
			var id = (point.x - boundingRect.position.x) * boundingRect.size.x \
	               + point.y - boundingRect.position.y
			id = int(id)
			pointsToIds[point] = id

	return pointsToIds


func _testMovementFrom( origin : Vector2, tester : KinematicBody2D) -> Array:
	var transform := Transform2D(0.0, origin)
	_shapeParams.transform = transform
	var isValidPlace = _space.intersect_shape(_shapeParams, 1).empty()
	var allowed := []

	if isValidPlace:
		for offset in _offsets:
			if _boundingRect.has_point(origin+offset) and !tester.test_move(transform, offset):
				allowed.append(origin+offset)

	return allowed
