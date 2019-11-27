extends Node2D

const AStarWrapper           = preload("res://AStarWrapper.gd")

const CellSize = Vector2(32, 32)

onready var sector = $'Sector'
onready var body = $'Body'
onready var astarWrapper = $'AStarWrapper'


func _ready():
	var tileRect = _calculateLevelRect(CellSize, [sector])

	var boundingRect = Rect2(
		tileRect.position.x * CellSize.x +1,
		tileRect.position.y * CellSize.y +1,
		tileRect.size.x * CellSize.x -1,
		tileRect.size.y * CellSize.y -1
		)

	var startTime := OS.get_system_time_msecs()

	astarWrapper.initialize(CellSize, boundingRect, Vector2(), body.get_node('CollisionShape2D'), body.rotation)
	astarWrapper.createGraph()

	print('elapsed : %s msec' % (OS.get_system_time_msecs() - startTime))


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
