extends CanvasItem

const CellSize = Vector2(32, 32)

var _path : PoolVector3Array
onready var _astar1 = $'AStar1'
onready var _body1 = $'Body1'


func _ready():
	var tileRect = _calculateLevelRect(CellSize, [$"Sector1"])

	var boundingRect = Rect2(
		tileRect.position.x * CellSize.x +1,
		tileRect.position.y * CellSize.y +1,
		tileRect.size.x * CellSize.x -1,
		tileRect.size.y * CellSize.y -1
		)

	_astar1.initialize(CellSize, boundingRect)
	_astar1.setCollisionShape(_body1.get_node('CollisionShape2D'))
	_createGraph()


func _input(event):
	if event is InputEventMouse:
		$'LabelMousePosition'.text = str(get_viewport().get_mouse_position())


func _draw():
#	return

	draw_rect( _astar1.getBoundingRect(), Color.blue, false )

	for edge in _astar1.getAStarEdges2D():
		draw_line(edge[0], edge[1], Color.purple, 1.0)

	for point in _astar1.getAStarPoints2D():
		draw_circle(point, 1, Color.cyan)

	for i in range(0, _path.size() - 1):
		draw_line(Vector2(_path[i].x, _path[i].y), Vector2(_path[i+1].x, _path[i+1].y) \
			, Color.yellow, 1.5)


func _calculateLevelRect( targetSize : Vector2, tilemapList : Array ) -> Rect2:
	var levelRect := Rect2()

	for tilemap in tilemapList:
		assert(tilemap is TileMap)
		var usedRect = tilemap.get_used_rect()
		var tilemapTargetRatio = tilemap.cell_size / targetSize * tilemap.scale
		usedRect.position *= tilemapTargetRatio
		usedRect.size *= tilemapTargetRatio
		levelRect = levelRect.merge(usedRect)

	return levelRect


func _createGraph():
	_astar1.create = true

#
#func _findPath():
#	_path.resize(0)
#	var astar = _astar1._astar
#	var startPoint = $'PositionStart'.global_position
#	var endPoint = $'PositionEnd'.global_position
#	var startId = astar.get_closest_point(Vector3(startPoint.x, startPoint.y, 0))
#	var endId = astar.get_closest_point(Vector3(endPoint.x, endPoint.y, 0))
#	_path = astar.get_point_path(startId, endId)
#
#	if _path.size():
#		$'Body'.position = Vector2(_path[0].x, _path[0].y)

