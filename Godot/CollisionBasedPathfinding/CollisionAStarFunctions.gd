extends Reference

const PointsDataGd =         preload("res://PointsData.gd")

const PointsData =           PointsDataGd.PointsData
const RESERVE_SPACE_MULT := 1.25
const X_COORD_MULT := 46000


func _init():
	assert(false)


static func calculateIdsForPoints(
		pointsData : PointsDataGd.PointsData, _boundingRect : Rect2 = Rect2() ) -> Dictionary:

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
		pointsData : PointsData, pointsToIds : Dictionary, isDiagonal : bool ) -> AStar2D:

	var astar := AStar2D.new()
	if pointsToIds.size() > 64:
		astar.reserve_space( int(pointsToIds.size() * RESERVE_SPACE_MULT) )

	for pt in pointsToIds:
		astar.add_point( pointsToIds[pt], pt )

	var connections := createConnections(pointsData, isDiagonal)
	for conn in connections:
		astar.connect_points( pointsToIds[conn[0]], pointsToIds[conn[1]] )

	return astar




static func createConnections(pointsData : PointsData, isDiagonal : bool) -> Array:
	var stepx := pointsData.step.x
	var stepy := pointsData.step.y
	var xcnt : int = pointsData.xCount
	var ycnt : int = pointsData.yCount
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
