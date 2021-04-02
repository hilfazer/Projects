extends Node

const FunctionsGd =          preload("res://CollisionAStarFunctions.gd")
const PointsDataGd =         preload("res://PointsData.gd")

const PointsData =           PointsDataGd.PointsData
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
	_pointsToIds = FunctionsGd.calculateIdsForPoints( _pointsData, boundingRect )
	_astar = FunctionsGd.createFullyConnectedAStar(_pointsData, _pointsToIds, _isDiagonal)
	return OK


func createGraph( unitShape : RectangleShape2D ) -> int:
	if not _pointsData:
		_printMessage("can't create a graph - builder was not properly initialized")
		return -1

	var graph := Graph.create( _astar )
	_previousGraphId += 1
	var id = _previousGraphId
	_graphs[id] = graph
	return id


func getAStar2D( graphId : int ) -> AStar2D:
	return _graphs[graphId].astar2d if _graphs.has(graphId) else null


func _printMessage( message : String, arguments : Array = [] ):
	print(name + " : " + message % arguments)




class Graph extends Reference:
	var astar2d : AStar2D

	func _init( astar_ : AStar2D ):
		astar2d = astar_


	static func create( astarReference : AStar2D ) -> Graph:
		# TODO
		return Graph.new( astarReference )
