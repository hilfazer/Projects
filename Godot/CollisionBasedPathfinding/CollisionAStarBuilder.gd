extends Node

const X_COORD_MULT = 45000
const MINIMUM_CELL_SIZE = Vector2(2, 2)


class PointsData:
	var topLeftPoint : Vector2
	var xCount : int
	var yCount : int
	var step : Vector2
# warning-ignore:unused_class_variable
	var offset : Vector2

var _astar := AStar2D.new()
var _boundingRect : Rect2
var _graphs := {}   # String(name) to Graph
var _isDiagonal : bool


func _init():
	name = get_script().resource_path.get_basename().get_file()


func initialize(
	cellSize : Vector2
	, boundingRect : Rect2
	, offset : Vector2 = Vector2()
	, isDiagonal : bool = false
	) -> int:

	if _boundingRect:
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

	_boundingRect = boundingRect
	_isDiagonal = isDiagonal
	return OK


func createGraph( graphName : String, unitShape : RectangleShape2D ):
	pass


func getAStar2D( graphName : String ) -> AStar2D:
	return _graphs[graphName].astar if _graphs.has(graphName) else null




func _printMessage( message : String, arguments : Array = [] ):
	print(name + " : " + message % arguments)


static func _makePointsData( step : Vector2, rect : Rect2, offset : Vector2 ) -> PointsData:
	assert(offset.x >= 0)
	assert(offset.y >= 0)

	var data = PointsData.new()

	var topLeft = (rect.position).snapped(step)
	topLeft += offset
	topLeft.x = topLeft.x if topLeft.x >= rect.position.x else topLeft.x + step.x
	topLeft.y = topLeft.y if topLeft.y >= rect.position.y else topLeft.y + step.y
	if topLeft.x - step.x >= rect.position.x:
		topLeft.x -= step.x
	if topLeft.y - step.y >= rect.position.y:
		topLeft.y -= step.y

	data.topLeftPoint = topLeft
	var xFirstToRectEnd = (rect.position.x + rect.size.x -1) - data.topLeftPoint.x
	data.xCount = int(xFirstToRectEnd / step.x) + 1

	var yFirstToRectEnd = (rect.position.y + rect.size.y -1) - data.topLeftPoint.y
	data.yCount = int(yFirstToRectEnd / step.y) + 1

	data.offset = offset
	data.step = step
	return data


static func _calculateIdsForPoints(
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




class Graph extends Reference:
	var astar := AStar2D.new()


	func _init(  ):
		pass






