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
var _astar := AStar.new()
var _testerShape := NodeGuard.new()
var _testerRotation := 0.0

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


func createGraph():
	assert(_testerShape.node != null)
	assert(is_inside_tree())

	var pointIds : Dictionary = _calculateIdsForPoints(_pointsData, _boundingRect, _step)
	var points : Array = []

	for x in _pointsData.xCount:
		for y in _pointsData.yCount:
			var point := Vector2(_pointsData.topLeftPoint.x + x * _step.x \
				, _pointsData.topLeftPoint.y + y * _step.y)
			points.append(point)

	for point in points:
		_astar.add_point( pointIds[point], Vector3(point.x, point.y, 0.0) )

	var connections : Array = _createConnections(_pointsData, getBoundingRect(), _step, _neighbourOffsets)

	for pointPair in connections:
		if pointIds.has(pointPair[0]) and pointIds.has(pointPair[1]):
			_astar.connect_points(pointIds[pointPair[0]], pointIds[pointPair[1]])

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
