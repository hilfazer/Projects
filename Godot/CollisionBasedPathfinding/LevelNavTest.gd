extends CanvasItem

const GraphBuilderGd         = preload("res://AStarGraphBuilder.gd")
const UnitGd                 = preload("res://Unit.gd")
const SectorGd               = preload("res://Sector.gd")
const ObstacleScn            = preload("res://Obstacle.tscn")
const SelectionComponentScn  = preload("res://SelectionComponent.tscn")

const WallTileId := 0

var _path : PoolVector3Array
var _currentSector : SectorGd = null
var _astarDataDict := {}
var _drawCalls := 0
onready var _drawCallsLabel : Label          = $'Panel/LabelDrawCalls'
onready var _drawEdgesCheckBox : CheckBox    = $'Panel/HBoxDrawing/CheckBoxEdges'
onready var _drawPointsCheckBox : CheckBox   = $'Panel/HBoxDrawing/CheckBoxPoints'
onready var _mousePosition                   = $'Panel/LabelMousePosition'
onready var _selection                       = $'SelectionComponent'

onready var _sectorNodes = [
	[$'Sector1', $'Panel/HBoxUnitChoice/Button1'],
	[$'Sector2', $'Panel/HBoxUnitChoice/Button2'],
	[$'Sector3', $'Panel/HBoxUnitChoice/Button3'],
	]


func _ready():
	for nodes in _sectorNodes:
		var sector : SectorGd = nodes[0]
		assert(sector.has_node("GraphBuilder"))
		assert(sector.has_node("Unit"))
		assert(sector.has_node("Position2D"))

		var unit : KinematicBody2D = sector.get_node("Unit")
		var graphBuilder : GraphBuilderGd = sector.get_node("GraphBuilder")
		var step : Vector2 = sector.step
		var selectButton : Button = nodes[1]

		var tileRect = _calculateLevelRect(step, [sector])

		var boundingRect = Rect2(
			tileRect.position.x * step.x +1,
			tileRect.position.y * step.y +1,
			tileRect.size.x * step.x -1,
			tileRect.size.y * step.y -1
			)

# warning-ignore:return_value_discarded
		graphBuilder.connect('graphCreated', self, '_positionUnit', [sector], CONNECT_ONESHOT)
# warning-ignore:return_value_discarded
		graphBuilder.connect('graphCreated', self, '_updateAStarPoints', [graphBuilder], CONNECT_ONESHOT)
# warning-ignore:return_value_discarded
		graphBuilder.connect('astarUpdated', self, '_updateAStarPoints', [graphBuilder])
# warning-ignore:return_value_discarded
		selectButton.connect("pressed", self, "_selectUnit", [unit])
# warning-ignore:return_value_discarded
		selectButton.connect("pressed", self, "_setCurrentSector", [sector])
# warning-ignore:return_value_discarded
		unit.connect('selected', self, "_selectUnit", [unit])

		var startTime := OS.get_system_time_msecs()

		graphBuilder.initialize(
			step, boundingRect, sector.pointsOffset, unit.get_node('CollisionShape2D'), unit.rotation)
		graphBuilder.createGraph([unit])

		print('initialize & createGraph : %s msec' % (OS.get_system_time_msecs() - startTime))


func _unhandled_input(event):
	if event is InputEventMouse:
		_mousePosition.text = str(get_viewport().get_mouse_position())
		if !_currentSector:
			return

		var newPath := _findPath(_currentSector)
		if newPath != _path:
			_path = newPath
			update()

	if event.is_action_pressed("moveUnit") and _currentSector and _path:
		_currentSector.get_node("Unit").followPath(_path)

	if event.is_action_pressed("alter_tile"):
		call_deferred("_onAlterTile")


func _draw():
	_drawCalls += 1
	_drawCallsLabel.text = "draw calls: %s" % _drawCalls

	for sectorAstarData in _astarDataDict.values():
		if _drawEdgesCheckBox.pressed:
			for edge in sectorAstarData['edges']:
				draw_line(edge[0], edge[1], Color.dimgray, 1.0)

		if _drawPointsCheckBox.pressed:
			for point in sectorAstarData['points']:
				draw_circle(point, 1, Color.cyan)

	for graphBuilder in _astarDataDict.keys():
		draw_rect( graphBuilder.getBoundingRect(), Color.blue, false )

	for i in range(0, _path.size() - 1):
		draw_line(Vector2(_path[i].x, _path[i].y), Vector2(_path[i+1].x, _path[i+1].y) \
			, Color.yellow, 1.5)


static func _calculateLevelRect( targetSize : Vector2, tilemapList : Array ) -> Rect2:
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


func _positionUnit(sector : SectorGd):
	var unit : KinematicBody2D = sector.get_node("Unit")
	var graphBuilder : GraphBuilderGd = sector.get_node("GraphBuilder")
	var pos2d = sector.get_node("Position2D")

	var pointId = graphBuilder.getAStar().get_closest_point(
		Vector3(pos2d.position.x, pos2d.position.y, 0) )
	var pointPos = graphBuilder.getAStar().get_point_position(pointId)
	pointPos = Vector2(pointPos.x, pointPos.y)
	unit.position = pointPos


func _selectUnit(unit : KinematicBody2D):
	_selection.get_parent().remove_child(_selection)
	unit.add_child(_selection)
	_selection.position = Vector2(0, 0)
	var sector : SectorGd = unit.get_parent()
	_setCurrentSector(sector)


func _setCurrentSector(sector : SectorGd):
	_currentSector = sector


func _findPath(sector : SectorGd) -> PoolVector3Array:
	var path := PoolVector3Array()
	var unit = sector.get_node("Unit")
	path.resize(0)
	var astar : AStar = sector.get_node("GraphBuilder").getAStar()
	var startPoint = unit.global_position
	var endPoint = get_viewport().get_mouse_position()
	var startId = astar.get_closest_point(Vector3(startPoint.x, startPoint.y, 0))
	var endId = astar.get_closest_point(Vector3(endPoint.x, endPoint.y, 0))
	path = astar.get_point_path(startId, endId)
	return path


func _updateAStarPoints(graphBuilder : GraphBuilderGd):
	_astarDataDict[graphBuilder] = {'edges' : null, 'points' : null}
	_astarDataDict[graphBuilder]['edges'] = graphBuilder.getAStarEdges2D()
	_astarDataDict[graphBuilder]['points'] = graphBuilder.getAStarPoints2D()


func _spawnObstacle():
	var obstacle = ObstacleScn.instance()
	add_child(obstacle)
	obstacle.position = get_viewport().get_mouse_position()


func _changeTileInSector(sector : SectorGd, worldPosition : Vector2) -> int:
	if not sector.boundingRect.has_point(worldPosition):
		return FAILED

	var cellPos := sector.world_to_map(worldPosition)
	if sector.get_cellv(cellPos) == -1:
		sector.set_cellv(cellPos, WallTileId)
	else:
		sector.set_cellv(cellPos, -1)
	return OK


func _onAlterTile():
	if not _currentSector:
		return

	var position = get_viewport().get_mouse_position()
	if _changeTileInSector(_currentSector, position) == OK:
		if _currentSector.get_node("GraphBuilder").has_method("updateGraph"):
			var unit : KinematicBody2D = _currentSector.get_node("Unit")

			var startTime := OS.get_system_time_msecs()
			_currentSector.get_node("GraphBuilder").updateGraph( \
					[_currentSector.boundingRect], [unit])
			print('updateGraph : %s msec' % (OS.get_system_time_msecs() - startTime))

	else:
		print("Failed to change a tile. Cursor outside of current sector.")
