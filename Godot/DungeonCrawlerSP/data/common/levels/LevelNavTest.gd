extends CanvasItem

const CellSize = Vector2(16, 16)

var _points := PoolVector2Array()
var _astar := AStar.new()


func _ready():
	var tileRect = _calculateLevelRect(CellSize)
	_points = _tileRectToPoints(tileRect)

	var boundingRect = Rect2(
		tileRect.position.x * CellSize.x -0,
		tileRect.position.y * CellSize.y -0,
		tileRect.size.x * CellSize.x +0,
		tileRect.size.y * CellSize.y +0
		)

	$'AStar'.initialize(CellSize, boundingRect)
	pass


func _draw():
	draw_rect( $'AStar'.getBoundingRect(), Color.blue, false )

	var pointsData = $'AStar'.getPointsData()
	var firstPoint = pointsData.topLeftPoint

	for x in range(0, pointsData.xCount):
		for y in range(0, pointsData.yCount):
			draw_circle(Vector2(firstPoint.x + x*CellSize.x, firstPoint.y + y*CellSize.y), 1, Color.cyan)


func _calculateLevelRect( targetSize : Vector2 ) -> Rect2:
	var usedGround = $'Ground'.get_used_rect()
	var groundTargetRatio = $'Ground'.cell_size / targetSize * $'Ground'.scale
	usedGround.position *= groundTargetRatio
	usedGround.size *= groundTargetRatio

	var usedWalls = $'Walls'.get_used_rect()
	var wallsTargetRatio = $'Walls'.cell_size / targetSize * $'Walls'.scale
	usedWalls.position *= groundTargetRatio
	usedWalls.size *= groundTargetRatio

	return usedGround.merge( usedWalls )


func _tileRectToPoints( tileRect : Rect2 ) -> PoolVector2Array:
	var points := PoolVector2Array()
	for x in range( tileRect.position.x + 1, tileRect.size.x + tileRect.position.x):
		for y in range( tileRect.position.y + 1, tileRect.size.y + tileRect.position.y):
			points.append(Vector2(x * CellSize.x, y * CellSize.y))

	return points

