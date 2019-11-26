extends Node

const NodeGuard = preload("./NodeGuard.gd")

const ShapeName := "Shape"

class PointsData:
	var topLeftPoint : Vector2
	var xCount : int
	var yCount : int


var _step : Vector2
var _neighbourOffsets := []
var _boundingRect : Rect2
var _pointsData : PointsData
var _pointsToIds : Dictionary = {}
var _astar := AStar.new()
var _testerShape := NodeGuard.new()
var _testerRotation := 0.0

var _space : Physics2DDirectSpaceState
var _shapeParams : Physics2DShapeQueryParameters


signal graphCreated()
signal astarUpdated()


func initialize(
		step : Vector2
		, boundingRect : Rect2
		, pointsOffset : Vector2
		, shape2d : CollisionShape2D
		, shapeRotation : float = 0.0 ):

	if _boundingRect:
		print ("%s already initialized" % [self.get_path()])
		return

	if not shape2d:
		print("Shape is null.")
		return

	_setStep(step)
	_boundingRect = boundingRect
	_pointsData = _makePointsData( step, boundingRect, pointsOffset )

	if not _boundingRect.has_point(_pointsData.topLeftPoint):
		print("Top left point %s is outside of bounding rectangle." % _pointsData.topLeftPoint)
		return

	_testerShape.setNode( shape2d.duplicate() )
	_testerShape.node.name = ShapeName
	_testerRotation = shapeRotation

	_pointsToIds = _calculateIdsForPoints(_pointsData, _boundingRect, _step)


func createGraph(bodiesToIgnore : Array = []):
	assert(_testerShape.node != null)
	assert(is_inside_tree())

	var points : Array = []

	for x in _pointsData.xCount:
		for y in _pointsData.yCount:
			var point := Vector2(_pointsData.topLeftPoint.x + x * _step.x \
				, _pointsData.topLeftPoint.y + y * _step.y)
			points.append(point)

	for point in points:
		assert(point is Vector2)
		_astar.add_point( _pointsToIds[point], Vector3(point.x, point.y, 0.0) )

	var tester := KinematicBody2D.new()
	tester.add_child(_testerShape.release())
	tester.rotation = _testerRotation
	for body in bodiesToIgnore:
		assert(body is PhysicsBody2D)
		tester.add_collision_exception_with(body)
	add_child(tester)

	_space = tester.get_world_2d().direct_space_state
	_shapeParams = Physics2DShapeQueryParameters.new()
	_shapeParams.collide_with_bodies = true
	_shapeParams.collision_layer = tester.collision_layer
	_shapeParams.transform = tester.transform
	_shapeParams.exclude = [tester] + tester.get_collision_exceptions()
	_shapeParams.shape_rid = tester.get_node(ShapeName).shape.get_rid()

	var enabledPoints := []
	var disabledPoints := _findDisabledPoints(_pointsToIds.keys(), tester, enabledPoints)
	assert(enabledPoints.size() + disabledPoints.size() == points.size())

	for point in disabledPoints:
		_astar.set_point_disabled(_pointsToIds[point])

	var connections : Array = _makeConnections(enabledPoints, tester)
	for conn in connections:
		assert(conn is Array and conn.size() == 2)
		_astar.connect_points( _pointsToIds[conn[0]], _pointsToIds[conn[1]] )

	emit_signal("astarUpdated")
	emit_signal("graphCreated")


func getBoundingRect() -> Rect2:
	return _boundingRect


func getAStar():
	return _astar


func getAStarPoints2D() -> Array:
	var pointArray := []
	for id in _astar.get_points():
		if _astar.is_point_disabled(id):
			continue

		var point3d : Vector3 = _astar.get_point_position(id)
		pointArray.append(Vector2(point3d.x, point3d.y))

	return pointArray


func getAStarEdges2D() -> Array:
	var edges := []
	for id in _astar.get_points():
		if _astar.is_point_disabled(id):
			continue

		var point3d : Vector3 = _astar.get_point_position(id)
		var connections : PoolIntArray = _astar.get_point_connections(id)
		for id_to in connections:
			var pointTo3d : Vector3 = _astar.get_point_position(id_to)
			edges.append(
				[ Vector2(point3d.x, point3d.y), Vector2(pointTo3d.x, pointTo3d.y) ] )

	return edges


func _setStep(step : Vector2):
	_step = step
	_neighbourOffsets = [
		Vector2(_step.x, -_step.y)
		, Vector2(_step.x, 0)
		, Vector2(_step.x, _step.y)
		, Vector2(0, _step.y)
		]


func _findDisabledPoints(points : Array, tester : KinematicBody2D, enabledPoints : Array) -> Array:
	var disabledPoints := []

	for pt in points:
		var transform := Transform2D(tester.rotation, pt)
		_shapeParams.transform = transform
		var isValidPlace = _space.intersect_shape(_shapeParams, 1).empty()
		if not isValidPlace:
			disabledPoints.append(pt)
		else:
			enabledPoints.append(pt)

	return disabledPoints


func _makeConnections(points : Array, tester : KinematicBody2D) -> Array:
	var connections := []

	for pt in points:
		for offset in _neighbourOffsets:
			var transform := Transform2D(tester.rotation, pt)
			_shapeParams.transform = transform
			if _boundingRect.has_point(pt+offset) and !tester.test_move(transform, offset):
				connections.append([pt, pt+offset])


	return connections


static func _makePointsData( step : Vector2, rect : Rect2, offset : Vector2 ) -> PointsData:
	var data = PointsData.new()

	data.topLeftPoint.x = stepify(rect.position.x + step.x/2, step.x) + offset.x
	var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - data.topLeftPoint.x
	data.xCount = int(xFirstToRectEnd / step.x) + 1

	data.topLeftPoint.y = stepify(rect.position.y + step.y/2, step.y) + offset.y
	var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - data.topLeftPoint.y
	data.yCount = int(yFirstToRectEnd / step.y) + 1

	return data


static func _calculateIdsForPoints(
		pointsData : PointsData, boundingRect : Rect2, step : Vector2) -> Dictionary:

	var pointsToIds := Dictionary()

	for x in pointsData.xCount:
		for y in pointsData.yCount:
			var point = Vector2(pointsData.topLeftPoint.x + x * step.x, pointsData.topLeftPoint.y + y * step.y)
			var id = (point.x - boundingRect.position.x) * boundingRect.size.x \
				   + point.y - boundingRect.position.y
			id = int(id)
			pointsToIds[point] = id

	return pointsToIds


static func _createConnections(
		pointsData : PointsData, boundingRect : Rect2, step : Vector2, offsets : Array) -> Array:

	var pointConnections := []

	for x in pointsData.xCount:
		for y in pointsData.yCount:
			var centralPoint := Vector2(pointsData.topLeftPoint.x + x * step.x \
				, pointsData.topLeftPoint.y + y * step.y)

			for offset in offsets:
				if boundingRect.has_point(centralPoint+offset):
					pointConnections.append([centralPoint, centralPoint+offset])

	return pointConnections
