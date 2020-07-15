extends CanvasItem

const LevNavTestGd           = preload("res://LevelNavTest.gd")
const GraphBuilderGd         = preload("res://CollisionAStarBuilder.gd")
const UnitGd                 = preload("res://Unit.gd")
const SectorGd               = preload("res://Sector.gd")

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

	var tileRect = LevNavTestGd.calculateLevelRect(step, [_sector])

	var boundingRect = Rect2(
		tileRect.position.x * step.x,
		tileRect.position.y * step.y,
		tileRect.size.x * step.x +1,
		tileRect.size.y * step.y +1
		)

	graphBuilder.initialize(step, boundingRect, _sector.pointsOffset, _sector.diagonal)
	_graphId = graphBuilder.createGraph(_sector.get_node("Unit/CollisionShape2D").shape)


func _draw():
	var astar : AStar2D = _sector.get_node("GraphBuilder").getAStar2D(_graphId)
	if astar == null:
		return

	if _drawPoints:
		for id in astar.get_points():
			draw_circle(astar.get_point_position(id), 1, Color.cyan)

#	if _drawEdges:
#		for id in astar.get_points():
#			draw_circle(astar.get_point_position(id), 1, Color.cyan)

