extends CanvasItem

const AStarWrapper = preload("res://AStarWrapper.gd")

const CellSize = Vector2(32, 32)

var _path : PoolVector3Array

onready var _sectorNodes = [
	[$'Sector1', $'Body1', $'AStarWrapper1', $'Position2D1'],
	[$'Sector2', $'Body2', $'AStarWrapper2', $'Position2D2'],
	]


func _ready():
	for nodes in _sectorNodes:
		var sector = nodes[0]
		var body = nodes[1]
		var astar : AStarWrapper = nodes[2]
		var position = nodes[3]

		var tileRect = _calculateLevelRect(CellSize, [sector])

		var boundingRect = Rect2(
			tileRect.position.x * CellSize.x +1,
			tileRect.position.y * CellSize.y +1,
			tileRect.size.x * CellSize.x -1,
			tileRect.size.y * CellSize.y -1
			)

		astar.initialize(CellSize, boundingRect, body.get_node('CollisionShape2D'))
		_createGraph(astar)


func _input(event):
	if event is InputEventMouse:
		$'LabelMousePosition'.text = str(get_viewport().get_mouse_position())


func _draw():
	for nodes in _sectorNodes:
		var astar = nodes[2]

		draw_rect( astar.getBoundingRect(), Color.blue, false )

		for edge in astar.getAStarEdges2D():
			draw_line(edge[0], edge[1], Color.purple, 1.0)

		for point in astar.getAStarPoints2D():
			draw_circle(point, 1, Color.cyan)

		for i in range(0, _path.size() - 1):
			draw_line(Vector2(_path[i].x, _path[i].y), Vector2(_path[i+1].x, _path[i+1].y) \
				, Color.yellow, 1.5)


func _calculateLevelRect( targetSize : Vector2, tilemapList : Array ) -> Rect2:
	var levelRect : Rect2

	for tilemap in tilemapList:
		assert(tilemap is TileMap)
		var usedRect = tilemap.get_used_rect()
		var tilemapTargetRatio = tilemap.cell_size / targetSize * tilemap.scale
		usedRect.position *= tilemapTargetRatio
		usedRect.size *= tilemapTargetRatio

		if not levelRect:
			levelRect = usedRect
		else:
			levelRect = levelRect.merge(usedRect)

	return levelRect


func _createGraph(astar):
	astar.createGraph()

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

