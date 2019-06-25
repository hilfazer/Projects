extends "res://core/level/FogVisionBase.gd"


export var _side := 100                setget setSide
var _excludedRID : RID                 setget setExcludedRID
var _visibilityMap := PoolByteArray()  setget deleted


func deleted(_a):
	assert(false)


func _ready():
	_visibilityMap.resize( _side * _side )

	# hack
	setExcludedRID( get_parent().get_rid() )


func calculateVisibleTiles(fogOfWar : TileMap ) -> PoolByteArray:
	var center := global_position
	var spaceState := get_world_2d().direct_space_state
	var tileCoordsRect := boundingRect(fogOfWar)
	var tileSize = fogOfWar.cell_size

	for line in lines:
		line.queue_free()
	lines.clear()

	var mapIdx := 0
	for x in range( tileCoordsRect.position.x, tileCoordsRect.size.x + tileCoordsRect.position.x):
		for y in range( tileCoordsRect.position.y, tileCoordsRect.size.y + tileCoordsRect.position.y):
			var targetCorner : Vector2 = fogOfWar.map_to_world( Vector2(x,y) )
			targetCorner.x += tileSize.x * float(targetCorner.x < center.x)
			targetCorner.y += tileSize.y * float(targetCorner.y < center.y)

			var occlusion = spaceState.intersect_ray( center, targetCorner, [_excludedRID] )
			_visibilityMap[mapIdx] = int(!occlusion || (occlusion.position - targetCorner).length() < 1)

			mapIdx += 1
#			var line = Line2D.new()
#			line.add_point(center)
#			line.add_point(targetCorner)
#			line.width = 1.5
#			line.default_color = Color.white if !occlusion || (occlusion.position - targetCorner).length() < 1 else Color.red
#			line.default_color.a = .1
#			lines.append(line)
#			fogOfWar.add_child(line)

	return _visibilityMap


func boundingRect( fogOfWar : TileMap ) -> Rect2:
	var rect = Rect2( 0, 0, _side, _side )
	var pos : Vector2 = fogOfWar.world_to_map( global_position )
	pos -= _rectOffset()
	rect.position = pos
	return rect


func setSide( side : int ):
	_side = side if side % 2 == 0 else side + 1
	_visibilityMap.resize( _side * _side )


func setExcludedRID( rid : RID ):
	_excludedRID = rid


func _rectOffset() -> Vector2:
	return Vector2( _side / 2.0, _side / 2.0 )


func _tileToPixelCenter(x, y, fogOfWar : TileMap):
	var corner := fogOfWar.map_to_world(Vector2(x, y))
	return corner + fogOfWar.cell_size / 2


#debug stuff
var lines := []

