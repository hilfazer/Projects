extends CanvasItem

const LevNavTestGd           = preload("res://LevelNavTest.gd")
const GraphBuilderGd         = preload("res://CollisionAStarBuilder.gd")
const UnitGd                 = preload("res://Unit.gd")
const SectorGd               = preload("res://Sector.gd")

export var _drawEdges := false
export var _drawPoints := false

var _astarDataDict := {}
onready var _sectors = [
	$"Sector1",
]


func _ready():
	for sector in _sectors:
		assert(sector.has_node("GraphBuilder"))
		assert(sector.has_node("Unit"))
		assert(sector.has_node("Position2D"))

		var unit : KinematicBody2D = sector.get_node("Unit")
		var graphBuilder : GraphBuilderGd = sector.get_node("GraphBuilder")
		var step : Vector2 = sector.step

		var tileRect = LevNavTestGd.calculateLevelRect(step, [sector])

		var boundingRect = Rect2(
			tileRect.position.x * step.x +1,
			tileRect.position.y * step.y +1,
			tileRect.size.x * step.x -1,
			tileRect.size.y * step.y -1
			)

		graphBuilder.initialize(step, boundingRect, sector.pointsOffset, sector.diagonal)


func _draw():
	if _astarDataDict.has("astar"):
		var astar : AStar2D = _astarDataDict["astar"]
		var pointArray := []
		for id in astar.get_points():
			pointArray.append( astar.get_point_position(id) )
	pass



func _selectSector(sector : TileMap):
	_astarDataDict["astar"] = sector.get_node("GraphBuilder")._astar

	update()
