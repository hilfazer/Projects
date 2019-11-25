extends CanvasItem

const AStarWrapper           = preload("res://AStarWrapper.gd")
const UnitGd                 = preload("res://Unit.gd")
const ObstacleScn            = preload("res://Obstacle.tscn")
const SelectionComponentScn  = preload("res://SelectionComponent.tscn")

const CellSize = Vector2(32, 32)

var _path : PoolVector3Array
var _currentUnit : UnitGd
var _astarDataDict := {}
var _drawCalls := 0
onready var _drawCallsLabel : Label          = $'Panel/LabelDrawCalls'
onready var _drawEdgesCheckBox : CheckBox    = $'Panel/HBoxDrawing/CheckBoxEdges'
onready var _drawPointsCheckBox : CheckBox   = $'Panel/HBoxDrawing/CheckBoxPoints'
onready var _mousePosition                   = $'Panel/LabelMousePosition'
onready var _selection                       = $'SelectionComponent'

onready var _sectorNodes = [
	[$'Sector1', $'Body1', $'AStarWrapper1', $'Position2D1', $'Panel/HBoxUnitChoice/Button1'],
	[$'Sector2', $'Body2', $'AStarWrapper2', $'Position2D2', $'Panel/HBoxUnitChoice/Button2'],
	[$'Sector3', $'Body3', $'AStarWrapper3', $'Position2D3', $'Panel/HBoxUnitChoice/Button3'],
	]


func _ready():
	for nodes in _sectorNodes:
		var sector = nodes[0]
		var body : KinematicBody2D = nodes[1]
		var astar : AStarWrapper = nodes[2]
		var selectButton : Button = nodes[4]

		var tileRect = _calculateLevelRect(CellSize, [sector])

		var boundingRect = Rect2(
			tileRect.position.x * CellSize.x +1,
			tileRect.position.y * CellSize.y +1,
			tileRect.size.x * CellSize.x -1,
			tileRect.size.y * CellSize.y -1
			)

		astar.initialize(CellSize, boundingRect, body.get_node('CollisionShape2D'), body.rotation)
# warning-ignore:return_value_discarded
		astar.connect('graphCreated', self, '_positionUnit', [nodes], CONNECT_ONESHOT)
# warning-ignore:return_value_discarded
		astar.connect('astarUpdated', self, '_updateAStarPoints', [astar])
# warning-ignore:return_value_discarded
		selectButton.connect("pressed", self, "_selectUnit", [body])
# warning-ignore:return_value_discarded
		body.connect('selected', self, "_selectUnit", [body])

		_createGraph(astar)


func _unhandled_input(event):
	if event is InputEventMouse:
		_mousePosition.text = str(get_viewport().get_mouse_position())
		if !_currentUnit:
			return

		var nodes = _findNodes(_currentUnit)
		assert(nodes != [])
		var newPath := _findPath(nodes)
		if newPath != _path:
			_path = newPath
			update()

	if event.is_action_pressed("moveUnit") and _currentUnit and _path:
		_currentUnit.followPath(_path)


func _draw():
	_drawCalls += 1
	_drawCallsLabel.text = "draw calls: %s" % _drawCalls

	for sectorAstarData in _astarDataDict.values():
		if _drawEdgesCheckBox.pressed:
			for edge in sectorAstarData['edges']:
				draw_line(edge[0], edge[1], Color.purple, 1.0)

		if _drawPointsCheckBox.pressed:
			for point in sectorAstarData['points']:
				draw_circle(point, 1, Color.cyan)

	for astarWrapper in _astarDataDict.keys():
		draw_rect( astarWrapper.getBoundingRect(), Color.blue, false )

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


func _createGraph(astar):
	astar.createGraph()


func _positionUnit(nodes : Array):
	var body = nodes[1]
	var astarWrapper : AStarWrapper = nodes[2]
	var pos2d = nodes[3]

	var pointId = astarWrapper.getAStar().get_closest_point(
		Vector3(pos2d.position.x, pos2d.position.y, 0) )
	var pointPos = astarWrapper.getAStar().get_point_position(pointId)
	pointPos = Vector2(pointPos.x, pointPos.y)
	body.position = pointPos


func _selectUnit(unit : KinematicBody2D):
	_currentUnit = unit
	_selection.get_parent().remove_child(_selection)
	unit.add_child(_selection)
	_selection.position = Vector2(0, 0)


func _findPath(nodes : Array) -> PoolVector3Array:
	var path := PoolVector3Array()
	var unit = nodes[1]
	path.resize(0)
	var astar : AStar = nodes[2].getAStar()
	var startPoint = unit.global_position
	var endPoint = get_viewport().get_mouse_position()
	var startId = astar.get_closest_point(Vector3(startPoint.x, startPoint.y, 0))
	var endId = astar.get_closest_point(Vector3(endPoint.x, endPoint.y, 0))
	path = astar.get_point_path(startId, endId)
	return path


func _findNodes(node : Node) -> Array:
	var nodeArray : Array = []

	for nodes in _sectorNodes:
		for n in nodes:
			if n == node:
				nodeArray = nodes
				break

	return nodeArray


func _updateAStarPoints(astarWrapper):
	_astarDataDict[astarWrapper] = {'edges' : null, 'points' : null}
	_astarDataDict[astarWrapper]['edges'] = astarWrapper.getAStarEdges2D()
	_astarDataDict[astarWrapper]['points'] = astarWrapper.getAStarPoints2D()


func _spawnObstacle():
	var obstacle = ObstacleScn.instance()
	add_child(obstacle)
	obstacle.position = get_viewport().get_mouse_position()
