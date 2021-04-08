extends CanvasItem

const GraphBuilderGd         = preload("./CollisionGraphBuilder.gd")
const UnitGd                 = preload("res://old_builder/Unit.gd")
const SectorGd               = preload("res://old_builder/Sector.gd")

export var _drawEdges := false
export var _drawPoints := false

var _astarDataDict := {}
onready var _sector = $"Sector1"
var _graphId : int = -1


func _ready():
	assert(_sector.has_node("GraphBuilder"))
	assert(_sector.has_node("Unit"))
	assert(_sector.has_node("Position2D"))

	var unit : KinematicBody2D = _sector.get_node("Unit")
	var graphBuilder : GraphBuilderGd = _sector.get_node("GraphBuilder")
	var step : Vector2 = _sector.step
	var boundingRect = GraphBuilderGd.calculateRectFromTilemaps([_sector], step)

	graphBuilder.initialize(step, boundingRect, _sector.pointsOffset, _sector.diagonal)
	var mask = 2
	_graphId = graphBuilder.createGraph(_sector.get_node("Unit/CollisionShape2D").shape, mask)


func _draw():
	var astar : AStar2D = _sector.get_node("GraphBuilder").getAStar2D(_graphId)
	if astar == null:
		return

	if _drawPoints:
		for id in astar.get_points():
			draw_circle(astar.get_point_position(id), 1, Color.cyan)

# TODO draw edges
#	if _drawEdges:
#		for id in astar.get_points():
#			draw_circle(astar.get_point_position(id), 1, Color.cyan)

