extends Reference

const PointsDataGd =         preload("./PointsData.gd")

const PointsData =           PointsDataGd.PointsData
const RESERVE_SPACE_MULT := 1.25
const X_COORD_MULT := 46000


func _init():
	assert(false)


static func calculateIdsForPoints(
		pointsData :PointsData, _boundingRect :Rect2 = Rect2() ) -> Dictionary:

	var pointsToIds := Dictionary()
	var stepx := pointsData.step.x
	var stepy := pointsData.step.y
	var xcnt : int = pointsData.xCount
	var ycnt : int = pointsData.yCount
	var tlx := pointsData.topLeftPoint.x
	var tly := pointsData.topLeftPoint.y
# warning-ignore:integer_division
	var offset := X_COORD_MULT / 2

	for x in range( tlx, tlx + xcnt * stepx, stepx ):
		for y in range( tly, tly + ycnt * stepy, stepy ):
			pointsToIds[ Vector2(x, y) ] = int((x+offset) * X_COORD_MULT + (y+offset))

	return pointsToIds


static func createFullyConnectedAStar(
		pointsData :PointsData, pointsToIds :Dictionary, isDiagonal :bool ) -> AStar2D:

	var astar := AStar2D.new()
	if pointsToIds.size() > 64: # TODO make it a const
		astar.reserve_space( int(pointsToIds.size() * RESERVE_SPACE_MULT) )

	for pt in pointsToIds:
		astar.add_point( pointsToIds[pt], pt )

	var connections := createConnections(pointsData, isDiagonal)
	for conn in connections:
		astar.connect_points( pointsToIds[conn[0]], pointsToIds[conn[1]] )

	return astar


static func createConnections(pointsData :PointsData, isDiagonal :bool) -> Array:
	var stepx := pointsData.step.x
	var stepy := pointsData.step.y
	var xcnt :int = pointsData.xCount
	var ycnt :int = pointsData.yCount
	var tlx := pointsData.topLeftPoint.x
	var tly := pointsData.topLeftPoint.y
	var connections := []

	if isDiagonal:
		for x in range( tlx, tlx + (xcnt-1) * stepx, stepx ):
			for y in range( tly, tly + (ycnt-1) * stepy, stepy ):
				connections.append( [Vector2(x,y)      , Vector2(x+stepx,y+stepy)] )
				connections.append( [Vector2(x+stepx,y), Vector2(x,y+stepy)] )
				connections.append( [Vector2(x,y)      , Vector2(x+stepx,y)] )
				connections.append( [Vector2(x,y)      , Vector2(x,y+stepy)] )
	else:
		for x in range( tlx, tlx + (xcnt-1) * stepx, stepx ):
			for y in range( tly, tly + (ycnt-1) * stepy, stepy ):
				connections.append( [Vector2(x,y)      , Vector2(x+stepx,y)] )
				connections.append( [Vector2(x,y)      , Vector2(x,y+stepy)] )

	var ylast := tly + (ycnt - 1) * stepy
	for x in range( tlx, tlx + (xcnt-1) * stepx, stepx ):
		connections.append( [Vector2(x, ylast), Vector2(x + stepx, ylast)] )

	var xlast := tlx + (xcnt - 1) * stepx
	for y in range( tly, tly + (ycnt-1) * stepy, stepy ):
		connections.append( [Vector2(xlast, y), Vector2(xlast, y + stepy)] )

	return connections


static func pointsFromRect( rectangle :Rect2, pointsData :PointsData ) -> Array:
	var rect := rectangle.clip(pointsData.boundingRect)
	var step = pointsData.step
	var topLeft = (rect.position).snapped(step)
	topLeft += pointsData.offset
	topLeft.x = topLeft.x if topLeft.x >= rect.position.x else topLeft.x + step.x
	topLeft.y = topLeft.y if topLeft.y >= rect.position.y else topLeft.y + step.y
	if topLeft.x - step.x >= rect.position.x:
		topLeft.x -= step.x
	if topLeft.y - step.y >= rect.position.y:
		topLeft.y -= step.y

	var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - topLeft.x
	var xCount = int(xFirstToRectEnd / step.x) + 1

	var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - topLeft.y
	var yCount = int(yFirstToRectEnd / step.y) + 1

	var points := []
	for x in range(topLeft.x, topLeft.x + xCount * step.x, step.x):
		for y in range(topLeft.y, topLeft.y + yCount * step.y, step.y):
			points.append( Vector2(x, y) )

	return points


static func pointsFromRectangles( rectangles :Array, pointsData :PointsData ) -> Dictionary:
	var points := {}

	for rect in rectangles:
		assert( rect is Rect2 )
		for pt in pointsFromRect(rect, pointsData):
			points[pt] = true

	return points
