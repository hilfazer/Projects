extends TileMap

# warning-ignore:unused_class_variable
export var step := Vector2(32, 32)
# warning-ignore:unused_class_variable
export var pointsOffset := Vector2(0,0)
# warning-ignore:unused_class_variable
export var diagonal : bool
# warning-ignore:unused_class_variable
onready var boundingRect := _calculateSectorRect([self])


static func _calculateSectorRect( tilemapList : Array ) -> Rect2:
	var levelRect : Rect2

	for tilemap in tilemapList:
		assert(tilemap is TileMap)
		var usedRect = tilemap.get_used_rect()
		var tilemapTargetRatio = tilemap.cell_size * tilemap.scale
		usedRect.position *= tilemapTargetRatio
		usedRect.size *= tilemapTargetRatio

		if not levelRect:
			levelRect = usedRect
		else:
			levelRect = levelRect.merge(usedRect)

	return levelRect
