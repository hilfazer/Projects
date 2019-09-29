extends CanvasItem

const CellSize = Vector2(16, 16)


func _ready():
	var tileRect = _calculateLevelRect(CellSize)

	var boundingRect = Rect2(
		tileRect.position.x * CellSize.x +1,
		tileRect.position.y * CellSize.y +1,
		tileRect.size.x * CellSize.x -1,
		tileRect.size.y * CellSize.y -1
		)

	$'AStar'.initialize(CellSize, boundingRect)
	$'AStar'.setCollisionShape($'Dwarf/CollisionShape2D')
	_createGraph()


func _draw():
	draw_rect( $'AStar'.getBoundingRect(), Color.blue, false )

	for point in $'AStar'.getAStarPoints2D():
		draw_circle(point, 1, Color.cyan)
	pass


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
