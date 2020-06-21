extends Node

const NodeGuard = preload("./NodeGuard.gd")

class PointsData:
	var topLeftPoint : Vector2
	var xCount : int
	var yCount : int
	var step : Vector2
	var offset : Vector2


var _neighbourOffsets := []
var _boundingRect : Rect2
var _pointsData : PointsData
var _pointsToIds : Dictionary = {}
var _astar := AStar.new()
var _tester := NodeGuard.new()

var _shapeParams : Physics2DShapeQueryParameters


signal graphCreated()
signal astarUpdated()


func initialize(
		step : Vector2
		, boundingRect : Rect2
		, pointsOffset : Vector2
		, diagonalConnections : bool
		, shape2d : CollisionShape2D
		, shapeRotation : float = 0.0):

	if _boundingRect:
		print ("%s already initialized" % [self.get_path()])
		return

	if not shape2d:
		print("Shape is null.")
		return

	_boundingRect = boundingRect
	_pointsData = _makePointsData( step, boundingRect, pointsOffset )
	_setStep(step, diagonalConnections)

	if not _boundingRect.has_point(_pointsData.topLeftPoint):
		print("Top left point %s is outside of bounding rectangle." % _pointsData.topLeftPoint)
		return

	_tester.setNode( _createAndSetupTester(shape2d.duplicate(), shapeRotation) )

	_pointsToIds = _calculateIdsForPoints(_pointsData, _boundingRect)


func createGraph(bodiesToIgnore):
	assert(_tester.node != null)
	assert(is_inside_tree())
	assert(is_a_parent_of(_tester.node))
	assert(_pointsToIds.size() != 0)

	var points := []

	for x in _pointsData.xCount:
		for y in _pointsData.yCount:
			var point := Vector2(_pointsData.topLeftPoint.x + x * _pointsData.step.x \
				, _pointsData.topLeftPoint.y + y * _pointsData.step.y)
			points.append(point)

	if _astar.has_method("reserve_space"):	#Godot 3.2
		_astar.reserve_space(int(_pointsData.xCount * _pointsData.yCount * 1.2))

	for point in points:
		assert(point is Vector2)
		_astar.add_point( _pointsToIds[point], Vector3(point.x, point.y, 0.0) )

	_setTesterCollisionExceptions(bodiesToIgnore)

	var ED_points := _findEnabledAndDisabledPoints(_pointsToIds.keys(), _tester.node)
	var enabledPoints : Array = ED_points[0]
	var disabledPoints : Array = ED_points[1]
	assert(enabledPoints.size() + disabledPoints.size() == points.size())

	for point in disabledPoints:
		_astar.set_point_disabled(_pointsToIds[point])

	var connections : Array = _findEnabledConnections(enabledPoints, disabledPoints, _tester.node)
	for conn in connections:
		assert(conn is Array and conn.size() == 2)
		_astar.connect_points( _pointsToIds[conn[0]], _pointsToIds[conn[1]] )

	remove_child(_tester.node)

	assert(not _tester.node.is_inside_tree())
	emit_signal("graphCreated")


func updateGraph(rectangles : Array, bodiesToIgnore):
	var points = _getPointsFromRectangles(rectangles, _pointsData, _boundingRect)

	add_child(_tester.node)
	_setTesterCollisionExceptions(bodiesToIgnore)

	var ED_points := _findEnabledAndDisabledPoints(points, _tester.node)
	var enabledPoints : Array = ED_points[0]
	var disabledPoints : Array = ED_points[1]
	assert(enabledPoints.size() + disabledPoints.size() == points.size())

	for pt in disabledPoints:
		_astar.set_point_disabled(_pointsToIds[pt], true)

	for pt in enabledPoints:
		_astar.set_point_disabled(_pointsToIds[pt], false)

	var ED_connections := _findEnabledAndDisabledConnections(points, disabledPoints, _tester.node)

	for conn in ED_connections[0]:
		assert(conn is Array and conn.size() == 2)
		_astar.connect_points( _pointsToIds[conn[0]], _pointsToIds[conn[1]] )

	for conn in ED_connections[1]:
		assert(conn is Array and conn.size() == 2)
		if _astar.are_points_connected(_pointsToIds[conn[0]], _pointsToIds[conn[1]]):
			_astar.disconnect_points( _pointsToIds[conn[0]], _pointsToIds[conn[1]] )

	remove_child(_tester.node)

	assert(not _tester.node.is_inside_tree())
	emit_signal("astarUpdated")


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


func _createAndSetupTester(shape__ : CollisionShape2D, rotation : float) -> KinematicBody2D:
	var tester := KinematicBody2D.new()
	tester.add_child(shape__)
	tester.rotation = rotation
	add_child(tester)

	_shapeParams = Physics2DShapeQueryParameters.new()
	_shapeParams.collide_with_bodies = true
	_shapeParams.collision_layer = tester.collision_layer
	_shapeParams.transform = tester.transform
	_shapeParams.exclude = [tester] + tester.get_collision_exceptions()
	_shapeParams.shape_rid = shape__.shape.get_rid()
	return tester


func _setTesterCollisionExceptions(exceptions : Array):
	var tester : PhysicsBody2D = _tester.node

	for node in tester.get_collision_exceptions():
		tester.remove_collision_exception_with(node)

	for body in exceptions:
		assert(body is PhysicsBody2D)
		tester.add_collision_exception_with(body)

	_shapeParams.exclude = [tester] + tester.get_collision_exceptions()


func _findEnabledAndDisabledPoints( \
		points : Array, tester : KinematicBody2D) -> Array:

	print("points: " + str(points.size()))
	var enabledAndDisabled := [[], []]
	var spaceState := tester.get_world_2d().direct_space_state

	for pt in points:
		var transform := Transform2D(tester.rotation, pt)
		_shapeParams.transform = transform
		var isValidPlace = spaceState.intersect_shape(_shapeParams, 1).empty()
		enabledAndDisabled[ int(!isValidPlace) ].append(pt)

	return enabledAndDisabled


#ignores connections involving disabled points
func _findEnabledConnections( \
		points : Array, disabledPoints : Array, tester : KinematicBody2D) -> Array:
		var disabledDict := {}	# for fast lookup
		for pt in disabledPoints:
			disabledDict[pt] = true

		var enabled := []

		for pt in points:
			for offset in _neighbourOffsets:
				var targetPt : Vector2 = pt+offset
				if not _boundingRect.has_point(targetPt) or disabledDict.has(targetPt):
					continue

				var transform := Transform2D(tester.rotation, pt)
				_shapeParams.transform = transform
				if !tester.test_move(transform, offset):
					enabled.append([pt, targetPt])

		return enabled


#ignores connections involving disabled points
func _findEnabledAndDisabledConnections( \
		points : Array, disabledPoints : Array, tester : KinematicBody2D) -> Array:
		var disabledDict := {}	# for fast lookup
		for pt in disabledPoints:
			disabledDict[pt] = true

		var enabledAndDisabled := [[], []]

		for pt in points:
			for offset in _neighbourOffsets:
				var targetPt : Vector2 = pt+offset
				if not _boundingRect.has_point(targetPt) or disabledDict.has(targetPt):
					continue

				var transform := Transform2D(tester.rotation, pt)
				_shapeParams.transform = transform
				var idx := int(tester.test_move(transform, offset))
				enabledAndDisabled[idx].append([pt, targetPt])

		return enabledAndDisabled


static func _getPointsFromRectangles(
		rectangles : Array, pointsData : PointsData, boundingRect : Rect2) -> Array:

	var points := {}
	var step : Vector2 = pointsData.step
	var offset := pointsData.offset

	for rect in rectangles:
		assert(rect is Rect2)
		rect = rect.clip( boundingRect )

		var rectTopLeftX := stepify(rect.position.x + step.x/2, step.x) + offset.x
		var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - rectTopLeftX
		var xCount = int(xFirstToRectEnd / step.x) + 1

		var rectTopLeftY := stepify(rect.position.y + step.y/2, step.y) + offset.y
		var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - rectTopLeftY
		var yCount = int(yFirstToRectEnd / step.y) + 1

		for x in range(xCount):
			for y in range(yCount):
				var point := Vector2(rectTopLeftX + x*step.x, rectTopLeftY + y*step.y)
				points[point] = true

	return points.keys()


static func _makePointsData( step : Vector2, rect : Rect2, offset : Vector2 ) -> PointsData:
	var data = PointsData.new()

	data.topLeftPoint.x = stepify(rect.position.x + step.x/2, step.x) + offset.x
	var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - data.topLeftPoint.x
	data.xCount = int(xFirstToRectEnd / step.x) + 1

	data.topLeftPoint.y = stepify(rect.position.y + step.y/2, step.y) + offset.y
	var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - data.topLeftPoint.y
	data.yCount = int(yFirstToRectEnd / step.y) + 1

	data.offset = offset
	return data


func _setStep(step : Vector2, diagonal : bool):
	_pointsData.step = step
	if diagonal:
		_neighbourOffsets = [
			Vector2(_pointsData.step.x, -_pointsData.step.y),
			Vector2(_pointsData.step.x, 0),
			Vector2(_pointsData.step.x, _pointsData.step.y),
			Vector2(0, _pointsData.step.y)
			]
	else:
		_neighbourOffsets = [
			Vector2(_pointsData.step.x, 0),
			Vector2(0, _pointsData.step.y)
			]


static func _calculateIdsForPoints(
		pointsData : PointsData, boundingRect : Rect2) -> Dictionary:

	var pointsToIds := Dictionary()
	var step = pointsData.step

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
