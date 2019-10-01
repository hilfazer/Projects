extends CanvasItem

const CellSize = Vector2(16, 16)

var _path : PoolVector3Array


func _ready():
	var tileRect = _calculateLevelRect(CellSize)

	var boundingRect = Rect2(
		tileRect.position.x * CellSize.x +1,
		tileRect.position.y * CellSize.y +1,
		tileRect.size.x * CellSize.x -1,
		tileRect.size.y * CellSize.y -1
		)

	$'AStar'.initialize(CellSize, boundingRect)
	$'AStar'.setCollisionShape($'Body/CollisionShape2D')
	$'AStar'.connect("graphCreated", self, "_findPath")
	_createGraph()


func _draw():
	return

	draw_rect( $'AStar'.getBoundingRect(), Color.blue, false )

	for edge in $'AStar'.getAStarEdges2D():
		draw_line(edge[0], edge[1], Color.purple, 1.0)

	for point in $'AStar'.getAStarPoints2D():
		draw_circle(point, 1, Color.cyan)

	for i in range(0, _path.size() - 1):
		draw_line(Vector2(_path[i].x, _path[i].y), Vector2(_path[i+1].x, _path[i+1].y) \
			, Color.yellow, 1.5)


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


func _createGraph():
	$'AStar'.create = true


func _findPath():
	_path.resize(0)
	var astar = $'AStar'._astar
	var startPoint = $'PositionStart'.global_position
	var endPoint = $'PositionEnd'.global_position
	var startId = astar.get_closest_point(Vector3(startPoint.x, startPoint.y, 0))
	var endId = astar.get_closest_point(Vector3(endPoint.x, endPoint.y, 0))
	_path = astar.get_point_path(startId, endId)

	if _path.size():
		$'Body'.position = Vector2(_path[0].x, _path[0].y)

