extends Node

const NodeGuard = preload("res://projects/NodeGuard.gd")

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
var _astar := AStar2D.new()
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
	_pointsData = makePointsData( step, boundingRect, pointsOffset )
	_setStep(step, diagonalConnections)

	if not _boundingRect.has_point(_pointsData.topLeftPoint):
		print("Top left point %s is outside of bounding rectangle." % _pointsData.topLeftPoint)
		return

	_tester.setNode( _createAndSetupTester(shape2d.duplicate(), shapeRotation) )

	_pointsToIds = calculateIdsForPoints(_pointsData, _boundingRect)


func createGraph(bodiesToIgnore):
	assert(_tester.node != null)
	assert(is_inside_tree())
	assert(is_a_parent_of(_tester.node))
	assert(_pointsToIds.size() != 0)

	var points := []
	var tlx := _pointsData.topLeftPoint.x
	var tly := _pointsData.topLeftPoint.y
	var stx := _pointsData.step.x
	var sty := _pointsData.step.y
	var xcnt := _pointsData.xCount
	var ycnt := _pointsData.yCount

	for x in xcnt:
		for y in ycnt:
			points.append( Vector2(tlx + x * stx, tly + y * sty) )

	_astar.reserve_space(int(_pointsData.xCount * _pointsData.yCount * 1.2))

	for point in points:
		assert(point is Vector2)
		_astar.add_point( _pointsToIds[point], point )

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

		var point : Vector2 = _astar.get_point_position(id)
		pointArray.append( point )

	return pointArray


func getAStarEdges2D() -> Array:
	var edges := []
	for id in _astar.get_points():
		if _astar.is_point_disabled(id):
			continue

		var point : Vector2 = _astar.get_point_position(id)
		var connections : PoolIntArray = _astar.get_point_connections(id)
		for id_to in connections:
			var pointTo : Vector2 = _astar.get_point_position(id_to)
			edges.append( [point, pointTo] )
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

	var enabledAndDisabled := [[], []]
	var spaceState := tester.get_world_2d().direct_space_state
	var transform := Transform2D(tester.rotation, Vector2())

	for pt in points:
		transform.origin = pt
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
	var transform := Transform2D(tester.rotation, Vector2())

	for pt in points:
		for offset in _neighbourOffsets:
			var targetPt : Vector2 = pt+offset
			if not _boundingRect.has_point(targetPt) or disabledDict.has(targetPt):
				continue

			transform.origin = pt
			if !tester.test_move(transform, offset):
				enabled.append([pt, targetPt])

	return enabled


#ignores connections involving disabled points
func _findEnabledAndDisabledConnections( \
		points : Array, disabledPoints : Array, tester : KinematicBody2D) -> Array:

	var disabledDict := {}  # for fast lookup
	for pt in disabledPoints:
		disabledDict[pt] = true

	var enabledAndDisabled := [[], []]
	var transform := Transform2D(tester.rotation, Vector2())

	for pt in points:
		for offset in _neighbourOffsets:
			var targetPt : Vector2 = pt+offset
			if not _boundingRect.has_point(targetPt) or disabledDict.has(targetPt):
				continue

			transform.origin = pt
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


static func makePointsData( step : Vector2, rect : Rect2, offset : Vector2 ) -> PointsData:
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


static func calculateIdsForPoints(
		pointsData : PointsData, boundingRect : Rect2) -> Dictionary:

	var pointsToIds := Dictionary()
	var stepx := pointsData.step.x
	var stepy := pointsData.step.y
	var xcnt : int = pointsData.xCount
	var ycnt : int = pointsData.yCount
	var tlx := pointsData.topLeftPoint.x
	var tly := pointsData.topLeftPoint.y
	var szx := boundingRect.size.x
	var bpx_szx_bpy = boundingRect.position.x * szx + boundingRect.position.y

	for x in range( tlx, tlx + xcnt * stepx, stepx ):
		for y in range( tly, tly + ycnt * stepy, stepy ):
			pointsToIds[ Vector2(x, y) ] = int(x * szx + y - bpx_szx_bpy)

	return pointsToIds
