extends Node

const X_COORD_MULT := 46000
const MINIMUM_CELL_SIZE := Vector2(2, 2)


var _astar := AStar2D.new()
var _pointsData : PointsData
var _pointsToIds := Dictionary()
var _isDiagonal : bool

var _previousGraphId := 0
var _graphs := {}   # String(name) to Graph


func _init():
	name = get_script().resource_path.get_basename().get_file()


func initialize(
	cellSize : Vector2
	, boundingRect : Rect2
	, offset : Vector2 = Vector2()
	, isDiagonal : bool = false
	) -> int:

	if _pointsData:
		_printMessage("%s already initialized", [get_path() if is_inside_tree() else @""])
		return ERR_ALREADY_EXISTS

	if cellSize.x < 1 or cellSize.y < 1:
		_printMessage("cellSize needs to be at least %s", [MINIMUM_CELL_SIZE])
		return ERR_CANT_CREATE

	if boundingRect.has_no_area():
		_printMessage("bounding rectangle needs to have an area")
		return ERR_CANT_CREATE

	if offset.x < 0 or offset.y < 0:
		_printMessage("negative offset is not supported( %s )", [offset])
		return ERR_CANT_CREATE

	if offset.x >= cellSize.x or offset.y >= cellSize.y:
		_printMessage("offset values %s need to be lower than cellSize values %s", [offset, cellSize])
		return ERR_CANT_CREATE

	_pointsData = PointsData.make(cellSize, boundingRect, offset)
	assert(_pointsData)
	_isDiagonal = isDiagonal
	_pointsToIds = calculateIdsForPoints( _pointsData, boundingRect )
	_astar = makeAStarPrototype(_pointsData, _pointsToIds, _isDiagonal)
	return OK


func createGraph( unitShape : RectangleShape2D ) -> int:
	if not _pointsData:
		_printMessage("can't create a graph - builder was not properly initialized")
		return -1


	_previousGraphId += 1
	return _previousGraphId


func getAStar2D( graphId : int ) -> AStar2D:
	return _graphs[graphId].astar if _graphs.has(graphId) else null


func _printMessage( message : String, arguments : Array = [] ):
	print(name + " : " + message % arguments)


static func calculateIdsForPoints(
		pointsData : PointsData, boundingRect : Rect2) -> Dictionary:

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


static func makeAStarPrototype( \
		pointsData : PointsData, pointsToIds : Dictionary, isDiagonal : bool ) -> AStar2D:

	var astar := AStar2D.new()
	if pointsToIds.size() > 64:
		astar.reserve_space( int(pointsToIds.size() * 1.25) )

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
				connections.append([Vector2(x,y), Vector2(x+stepx,y+stepy)])
				connections.append([Vector2(x+stepx,y), Vector2(x,y+stepy)])
				connections.append([Vector2(x,y), Vector2(x+stepx,y)])
				connections.append([Vector2(x,y), Vector2(x,y+stepy)])
	else:
		for x in range( tlx, tlx + (xcnt-1) * stepx, stepx ):
			for y in range( tly, tly + (ycnt-1) * stepy, stepy ):
				connections.append([Vector2(x,y), Vector2(x+stepx,y)])
				connections.append([Vector2(x,y), Vector2(x,y+stepy)])

	var ylast := tly + (ycnt - 1) * stepy
	for x in range( tlx, tlx + (xcnt-1) * stepx, stepx ):
		connections.append([Vector2(x, ylast), Vector2(x + stepx, ylast)])

	var xlast := tlx + (xcnt - 1) * stepx
	for y in range( tly, tly + (ycnt-1) * stepy, stepy ):
		connections.append([Vector2(xlast, y), Vector2(xlast, y + stepy)])

	return connections



class PointsData:
	var topLeftPoint : Vector2
	var xCount : int
	var yCount : int
	var step : Vector2
# warning-ignore:unused_class_variable
	var offset : Vector2
	var boundingRect : Rect2

	static func make( step_ : Vector2, rect : Rect2, offset_ : Vector2 = Vector2() ) -> PointsData:
		assert(offset_.x >= 0)
		assert(offset_.y >= 0)

		var data = PointsData.new()

		var topLeft = (rect.position).snapped(step_)
		topLeft += offset_
		topLeft.x = topLeft.x if topLeft.x >= rect.position.x else topLeft.x + step_.x
		topLeft.y = topLeft.y if topLeft.y >= rect.position.y else topLeft.y + step_.y
		if topLeft.x - step_.x >= rect.position.x:
			topLeft.x -= step_.x
		if topLeft.y - step_.y >= rect.position.y:
			topLeft.y -= step_.y
		data.topLeftPoint = topLeft

		var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - data.topLeftPoint.x
		data.xCount = int(xFirstToRectEnd / step_.x) + 1

		var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - data.topLeftPoint.y
		data.yCount = int(yFirstToRectEnd / step_.y) + 1

		data.offset = offset_
		data.step = step_
		data.boundingRect = rect
		return data



class Graph extends Reference:
	var astar := AStar2D.new()

	func _init(  ):
		pass






